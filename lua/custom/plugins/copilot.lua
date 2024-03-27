return {
  { -- GitHub Copilot AI
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = true,
          auto_trigger = false,
          keymap = {
            next = '<C-Right>',
            prev = '<C-Left>',
            accept = '<C-Down>',
            accept_word = '<C-Up>',
          },
        },
        filetypes = {
          sh = function()
            if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
              -- disable for .env files
              return false
            end
            return true
          end,
        },
      }
    end,
  },
}
