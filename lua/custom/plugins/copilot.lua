return {
  { -- GitHub Copilot AI
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            next = '<C-l>',
            prev = '<C-h>',
            accept = '<Tab>',
            accept_word = '<C-)>',
            accept_line = '<C-j>',
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
