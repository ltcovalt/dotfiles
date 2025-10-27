-- NOTE: [[ VIM GLOBALS ]]
--
-- Set <space> as the leader key
-- See `:help mapleader`
-- Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

-- NOTE: [[ VIM OPTIONS ]]
-- see `:help vim.o`
-- for more options, see `:help option-list`

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.o.breakindent = true -- enable break indent
vim.o.mouse = "a" -- enable mouse for all modes
vim.o.number = true -- enable line numbers - displays current line if relativenumber is also enabled
vim.o.ignorecase = true -- enable case insensitive searching
vim.o.relativenumber = true -- enable relative line numbers
vim.o.undofile = true -- save undo history
vim.o.updatetime = 250 -- decrease update time
vim.o.showmode = false -- don't show mode since it is already in the status line
vim.o.signcolumn = "yes" -- Keep signcolumn on by default
vim.o.smartcase = true -- UNLESS \C or one or more catital letters is in the search term
vim.o.splitright = true -- vertical splits to open to the right
vim.o.splitbelow = true -- horizontal splits open to the bottom
vim.o.termguicolors = true -- enable 24 bit color in the TUI
vim.o.timeout = true -- enable mapped key timeout
vim.o.timeoutlen = 500 -- 500ms timeout for multi-key mappings
vim.o.wrap = false -- disable word wrap by default

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.o.list = true

--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.inccommand = "split" -- preview substitutions live while typing
vim.o.cursorline = true -- highlight the line the cursor is on
vim.o.scrolloff = 8 -- number of lines to keep visible above and below the cursor
vim.o.confirm = true -- show confirm dialog when closing an unsaved buffer

-- auto indent options
local indentWidth = 2
vim.o.expandtab = true
vim.o.shiftwidth = indentWidth
vim.o.tabstop = indentWidth
vim.o.softtabstop = indentWidth
vim.o.autoindent = true
vim.o.smartindent = true

-- NOTE: [[ KEYMAPS ]]
--  See `:help vim.keymap.set()`
require("keymaps")

-- NOTE: [[ AUTOCOMMANDS ]]
--  See `:help lua-guide-autocommands`
require("autocommands")

-- NOTE: [[ PLUGIN MANAGER: install lazy.nvim ]]
--  See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- NOTE: [[ PLUGINS: install lazy plugins ]]
-- check the current status of lazy plugins by running :Lazy
-- use `?` for help and `:q` to close the lazy window
require("lazy").setup({

	-- NOTE: Plugins can also be added by using a table,
	-- with the first argument being the link and the following
	-- keys can be used to configure plugin behavior/loading/etc.
	-- For this setup, all plugins have been separated into their own files

	-- NOTE: plugins can be added with a direct link
	-- or for a github repo 'owner/repo' link
	"NMAC427/guess-indent.nvim", -- Detect tabstop and shiftwidth automatically

	-- NOTE: an entire plugin directory can be imported
	-- { import = 'plugins' },

	-- NOTE: or plugins can be imported individually
	{ import = "plugins.autopairs" }, -- inserts [({})] in matching pairs
	{ import = "plugins.blink" }, -- auto-completion
	{ import = "plugins.colorschemes" }, -- additional themes/colorschemes
	{ import = "plugins.conform" }, -- auto-formatting
	-- { import = 'plugins.debug' }, -- dap plugin for debugging code, configured for golang by default
	{ import = "plugins.gitsigns" }, -- add git status lines beside line numbers
	{ import = "plugins.indent_line" }, -- displays visual line indents
	{ import = "plugins.lazydev" }, -- configures LUA LSP for nvim congigs
	-- { import = 'plugins.lint' }, -- provides multiple linters
	{ import = "plugins.lsp" }, -- main LSP configuration
	{ import = "plugins.lualine" }, -- status bar
	{ import = "plugins.markdown" }, -- mdx syntax highlighting
	{ import = "plugins.mini" }, -- collection of small plugins
	{ import = "plugins.neo-tree" }, -- directory browser
	{ import = "plugins.noice" }, -- a noice looking cli
	{ import = "plugins.telescope" }, -- telescope fuzzy finder
	{ import = "plugins.treesitter" }, -- highlight, edit, and navigate code
	{ import = "plugins.todo-comments" }, -- todo/note/warn
	{ import = "plugins.which-key" }, -- displays live previews when typing keybinds
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
