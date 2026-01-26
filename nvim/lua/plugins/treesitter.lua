return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
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

		ts.setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})

		ts.install(install_languages)

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
