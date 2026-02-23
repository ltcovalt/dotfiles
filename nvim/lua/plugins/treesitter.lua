return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		local configs = require("nvim-treesitter.configs")
		local install_languages = {
			"bash",
			"c",
			"diff",
			"html",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"query",
			"vim",
			"vimdoc",
			"astro",
			"typescript",
			"css",
			"javascript",
			"tsx",
		}

		configs.setup({
			ensure_installed = install_languages,
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
			textobjects = {
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]m"] = "@function.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
					},
					goto_next_end = {
						["]M"] = "@function.outer",
					},
					goto_previous_end = {
						["[M"] = "@function.outer",
					},
				},
				select = {
					enable = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
					},
				},
			},
		})

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local ft = vim.bo[args.buf].filetype
				if vim.tbl_contains(install_languages, ft) then
					vim.treesitter.start(args.buf)
					if ft ~= "ruby" then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end
			end,
		})
	end,
}
