return {
  {
    'folke/trouble.nvim',
    config = function()
      require('trouble').setup {
        icons = false,
      }

      vim.keymap.set('n', '<leader>wd', function()
        require('trouble').toggle 'workspace_diagnostics'
      end, { silent = true, noremap = true, desc = 'Trouble [W]orkspace [D]iagnostics' })

      vim.keymap.set('n', '<leader>dd', function()
        require('trouble').toggle 'document_diagnostics'
      end, { silent = true, noremap = true, desc = 'Trouble [D]ocument [D]iagnostics' })

      vim.keymap.set('n', '<leader>wq', function()
        require('trouble').toggle 'quickfix'
      end, { silent = true, noremap = true, desc = 'Trouble [W]orkspace [Q]uickfix' })
    end,
  },
}
