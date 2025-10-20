-- lua/plugins/colorschemes.lua
return {
  {
    'folke/tokyonight.nvim',
    lazy = false, -- load at startup (so priority is respected)
    priority = 1000,
    config = function()
      require('tokyonight').setup {
        styles = { comments = { italic = false } },
      }
    end,
  },
  {
    'sainnhe/sonokai',
    lazy = false, -- load at startup
    priority = 1000,
    config = function()
      vim.g.sonokai_enable_italic = true
      vim.cmd.colorscheme 'sonokai' -- set as default colorscheme
    end,
  },
}
