-- Highlight when yanking (copying) text
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Ensure comment leaders are continued on new lines (r = Enter, o = o/O)
-- Done via FileType autocmd so it runs after filetype plugins that reset formatoptions
vim.api.nvim_create_autocmd("FileType", {
	desc = "Ensure comment leaders are continued on new lines",
	group = vim.api.nvim_create_augroup("format-options", { clear = true }),
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:append("ro")
	end,
})

-- Treat hyphenated-words as a single word in HTML, CSS, and Svelte
vim.api.nvim_create_autocmd("FileType", {
	desc = "Treat hyphenated-words as a single word",
	group = vim.api.nvim_create_augroup("iskeyword-hyphen", { clear = true }),
	pattern = { "html", "css", "svelte" },
	callback = function()
		vim.opt_local.iskeyword:append("-")
	end,
})


-- Auto-expand /* or /** into a full block comment when Enter is pressed.
-- Returns "" to consume the CR (preventing blink.cmp from accepting a ts_ls JSDoc snippet),
-- then inserts ' * ' and ' */' via vim.schedule. {} etc. fall through to autopairs.
local function setup_comment_close()
	-- replace_keycodes = false: autopairs_cr() returns already-encoded bytes;
	-- without this, Neovim double-processes them and inserts raw <80> garbage.
	vim.keymap.set("i", "<CR>", function()
		local line = vim.api.nvim_get_current_line()
		local row = vim.api.nvim_win_get_cursor(0)[1]

		-- Only intercept when the line is solely /* or /**. Everything else
		-- (blocks, parens, arrays) is left entirely to autopairs and treesitter.
		local comment_indent = line:match("^(%s*)%/%*+%s*$")
		if comment_indent then
			-- Check if the line below already starts with optional spaces and '*' or '*/'
			local next_line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
			local is_already_closed = next_line and (next_line:match("^%s*%*") or next_line:match("^%s*%*/"))

			if not is_already_closed then
				-- Scan the lines below to see if there is a closing '*/' before any new '/*' or '/**'
				local line_count = vim.api.nvim_buf_line_count(0)
				local scan_limit = math.min(row + 50, line_count)
				for r = row, scan_limit - 1 do
					local l = vim.api.nvim_buf_get_lines(0, r, r + 1, false)[1]
					if l then
						local idx_close = l:find("%*/")
						local idx_open = l:find("/%*")
						if idx_close and idx_open then
							if idx_close < idx_open then
								is_already_closed = true
								break
							elseif idx_open < idx_close then
								break
							end
						elseif idx_close then
							is_already_closed = true
							break
						elseif idx_open then
							break
						end
					end
				end
			end

			if not is_already_closed then
				-- Return "" (consume the CR without inserting it) so blink.cmp never
				-- sees the Enter and can't accept a ts_ls JSDoc snippet completion.
				-- vim.schedule inserts the two new lines after the expr mapping exits.
				vim.schedule(function()
					vim.api.nvim_buf_set_lines(0, row, row, false, {
						comment_indent .. " * ",
						comment_indent .. " */",
					})
					vim.api.nvim_win_set_cursor(0, { row + 1, #(comment_indent .. " * ") })
				end)
				return ""
			end
		end

		local ok, npairs = pcall(require, "nvim-autopairs")
		if ok then return npairs.autopairs_cr() end
		return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
	end, { expr = true, replace_keycodes = false, buffer = true })
end

vim.api.nvim_create_autocmd("FileType", {
	desc = "Auto-close block comments with */ on Enter",
	group = vim.api.nvim_create_augroup("comment-close", { clear = true }),
	pattern = { "javascript", "typescript", "typescriptreact", "javascriptreact", "css" },
	callback = setup_comment_close,
})

-- Enaable built-in spell checker for markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "markdown.mdx" },
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = { "en_us" }
	end,
})

-- Custom JSDoc/multiline comment indentation override.
-- This aligns the '*' of the new line with the '*' of the line above it,
-- and falls back to Treesitter or native indentation for normal code.
_G.custom_jsdoc_indent = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local lnum = vim.v.lnum

	-- 1. Check if we are inside a JSDoc comment. If so, return the aligned column!
	local prev_lnum = lnum - 1
	if prev_lnum > 0 then
		local prev_line = vim.api.nvim_buf_get_lines(bufnr, prev_lnum - 1, prev_lnum, false)[1]
		if prev_line then
			local is_comment_start = prev_line:match("^%s*/%*")
			local is_comment_middle = prev_line:match("^%s*%*")
			local is_comment_end = prev_line:match("%*/%s*$")

			if (is_comment_start or is_comment_middle) and not is_comment_end then
				local idx = prev_line:find("%*")
				if idx then
					local prefix = prev_line:sub(1, idx - 1)
					return vim.fn.strdisplaywidth(prefix)
				end
			end
		end
	end

	-- 2. If we are NOT in JSDoc, fall back to Treesitter if active
	local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr)
	if ok_parser and parser then
		-- Call it directly inside pcall to trigger Vimscript autoload if not yet loaded
		local ok, res = pcall(vim.api.nvim_eval, "nvim_treesitter#indent()")
		if ok then
			return res
		end
	end

	-- 3. Otherwise, fall back to native JS/TS indent functions
	local ft = vim.bo[bufnr].filetype
	if ft == "javascript" or ft == "javascriptreact" then
		if vim.fn.exists("*GetJavascriptIndent") == 1 then
			local ok, res = pcall(vim.api.nvim_eval, "GetJavascriptIndent()")
			if ok then return res end
		end
	elseif ft == "typescript" or ft == "typescriptreact" or ft == "tsx" then
		if vim.fn.exists("*GetTypescriptIndent") == 1 then
			local ok, res = pcall(vim.api.nvim_eval, "GetTypescriptIndent()")
			if ok then return res end
		end
	end

	-- 4. Final fallback
	return -1
end

vim.api.nvim_create_autocmd("FileType", {
	desc = "Override indentexpr for JSDoc alignment in JS/TS files",
	group = vim.api.nvim_create_augroup("jsdoc-indent-override", { clear = true }),
	pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "tsx" },
	callback = function(event)
		local bufnr = event.buf

		-- Remove single-line comment auto-continuation on Enter, keeping JSDoc continuation
		vim.opt_local.comments:remove("://")

		-- Defer the indentexpr override to run after Treesitter has finished attaching and setting indentexpr
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then return end
			vim.bo[bufnr].indentexpr = "v:lua.custom_jsdoc_indent()"
		end)
	end,
})

