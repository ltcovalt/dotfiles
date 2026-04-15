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
