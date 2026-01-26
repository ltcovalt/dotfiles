return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
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
