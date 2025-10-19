return {
  'rcarriga/nvim-notify',
  lazy = false,
  priority = 1000,
  opts = {
    timeout = 2000,
    render = 'minimal',
    max_width = 40,
    max_height = 4,
    stages = 'fade_in_slide_out',
    top_down = false,
  },
  config = function(_, opts)
    local n = require 'notify'
    n.setup(opts)
    vim.notify = n -- ensure everyone uses nvim-notify
  end,
}
