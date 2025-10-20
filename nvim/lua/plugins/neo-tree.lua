-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },

  opts = {
    sources = { 'filesystem', 'buffers', 'git_status' },

    source_selector = {
      winbar = true,
      sources = {
        { source = 'filesystem', display_name = '󰉓 files' }, -- folder
        { source = 'buffers', display_name = '󰈙 buffers' }, -- file
        { source = 'git_status', display_name = '󰊢 git' }, -- git
      },
    },

    filesystem = {
      window = { mappings = { ['\\'] = 'close_window' } },
    },
  },
}
