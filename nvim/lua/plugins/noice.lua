return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' },
  opts = {
    -- ":" commandline as a floating popup
    cmdline = { view = 'cmdline_popup' },

    -- route messages to toast notifications
    messages = {
      enabled = true,
      view = 'notify',
      view_error = 'notify',
      view_warn = 'notify',
      view_search = false, -- hide incremental search counter bubble
    },

    -- enable notify view integration
    notify = { enabled = true, view = 'notify' },

    -- Noice-owned popups (toast sizing is in notify.lua)
    views = {
      cmdline_popup = {
        position = { row = '95%', col = '50%', anchor = 'SW' },
        size = { width = 60, height = 'auto' },
        border = { style = 'rounded', padding = { 0, 1 } },
      },
      notify = { timeout = 2000, replace = true },
    },

    -- optional noise reductions
    routes = {
      { filter = { event = 'msg_show', kind = 'search_count' }, opts = { skip = true } },
      { filter = { event = 'msg_show', find = 'written' }, opts = { skip = true } },
    },
  },
}
