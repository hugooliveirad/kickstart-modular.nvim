-- Diffview.nvim - Git diff viewer
-- Provides a rich interface for reviewing diffs and file history

return {
  'sindrets/diffview.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  cmd = {
    'DiffviewOpen',
    'DiffviewClose',
    'DiffviewToggleFiles',
    'DiffviewFocusFiles',
    'DiffviewRefresh',
    'DiffviewFileHistory',
  },
  keys = {
    { '<leader>dv', '<cmd>DiffviewOpen<cr>', desc = 'Open Diffview' },
    { '<leader>dc', '<cmd>DiffviewClose<cr>', desc = 'Close Diffview' },
    { '<leader>dh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File History (current)' },
    { '<leader>dH', '<cmd>DiffviewFileHistory<cr>', desc = 'File History (all)' },
  },
  opts = {
    enhanced_diff_hl = true,
    use_icons = false,
    signs = {
      fold_closed = '+',
      fold_open = '-',
      done = '✓',
    },
  },
}
