local utils = require 'utils'

return {
  'esmuellert/codediff.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  cmd = 'CodeDiff',
  keys = {
    { '<leader>dd', '<cmd>CodeDiff<cr>', desc = 'Open CodeDiff (git status)' },
    { '<leader>df', '<cmd>CodeDiff file<cr>', desc = 'Open CodeDiff (file)' },
    {
      '<leader>dm',
      function()
        vim.cmd('CodeDiff ' .. utils.get_parent_branch() .. '...')
      end,
      desc = 'Open CodeDiff (merge-base vs working tree)',
    },
    {
      '<leader>dh',
      function()
        vim.cmd('CodeDiff history ' .. utils.get_parent_branch() .. '..HEAD')
      end,
      desc = 'Open CodeDiff History (parent..HEAD)',
    },
    { '<leader>dH', '<cmd>CodeDiff history<cr>', desc = 'Open CodeDiff History (all)' },
  },
  keymaps = {
    view = {
      next_hunk = ']g',
      prev_hunk = '[g',
    },
  },
}
