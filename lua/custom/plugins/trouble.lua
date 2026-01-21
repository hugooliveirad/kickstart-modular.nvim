return {
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {
      -- ASCII icons for non-nerd-font setups (trouble.nvim v3 requires a table)
      icons = {
        indent = {
          top = '| ',
          middle = '|-',
          last = '`-',
          fold_open = 'v ',
          fold_closed = '> ',
          ws = '  ',
        },
        folder_closed = '+ ',
        folder_open = '- ',
        kinds = {},
      },
    },
    keys = {
      -- v3 mode names: diagnostics, qflist, loclist, symbols, lsp, etc.
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Trouble Diagnostics' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Trouble Buffer Diagnostics' },
      { '<leader>xq', '<cmd>Trouble qflist toggle<cr>', desc = 'Trouble Quickfix' },
      { '<leader>xl', '<cmd>Trouble loclist toggle<cr>', desc = 'Trouble Location List' },
    },
  },
}
