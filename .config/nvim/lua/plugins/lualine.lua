return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  config = function()
    -- Macro rec indicator
    local function macro_recording()
      local reg = vim.fn.reg_recording()
      return (reg ~= '' and (' @' .. reg)) or ''
    end

    -- Optional: Noice status components (safe-guarded)
    local function noice_mode()
      local ok, api = pcall(require, 'noice')
      return ok and api.api.status.mode.get and api.api.status.mode.get() or ''
    end
    local function noice_has()
      local ok, api = pcall(require, 'noice')
      return ok and api.api.status.mode.has and api.api.status.mode.has()
    end

    require('lualine').setup {
      options = {
        theme = 'auto',
        globalstatus = true,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        disabled_filetypes = { 'neo-tree', 'lazy', 'mason', 'Trouble' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = {
          { noice_mode, cond = noice_has }, -- shows Noice cmdline/mode if present
          macro_recording,
          'encoding',
          'fileformat',
          'filetype',
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { 'quickfix', 'fugitive', 'man', 'nvim-dap-ui', 'toggleterm' },
    }

    -- Refresh when macro rec start/stop so the indicator updates immediately
    vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
      callback = function()
        vim.cmd 'redrawstatus'
      end,
    })
  end,
}
