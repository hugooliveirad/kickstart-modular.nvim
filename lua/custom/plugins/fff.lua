return {
  'dmtrKovalenko/fff.nvim',
  build = function()
    require('fff.download').download_or_build_binary()
  end,
  lazy = false,
  config = function(_, opts)
    require('fff').setup(opts)
    -- Disable icons in fff without affecting other plugins
    local icons = require 'fff.file_picker.icons'
    icons.provider = nil
    icons.provider_name = nil
    icons.setup_failed = true
  end,
  opts = {
    layout = {
      preview_position = 'top',
    },
    keymaps = {
      move_down = { '<Down>', '<C-n>', '<C-j>' },
      move_up = { '<Up>', '<C-p>', '<C-k>' },
    },
  },
  keys = {
    { '<leader>sf', function() require('fff').find_files() end, desc = '[S]earch [F]iles (fff)' },
    { '<C-p>', function() require('fff').find_files() end, desc = '[S]earch [F]iles (fff)' },
    { '<leader>sg', function() require('fff').live_grep() end, desc = '[S]earch by [G]rep (fff)' },
    {
      '<leader>sw',
      function()
        local word = vim.fn.expand '<cword>'
        require('fff').live_grep()
        vim.schedule(function() vim.api.nvim_feedkeys(word, 'n', false) end)
      end,
      desc = '[S]earch current [W]ord (fff)',
    },
    {
      '<leader>sw',
      function()
        local old_reg = vim.fn.getreg '"'
        local old_regtype = vim.fn.getregtype '"'
        vim.cmd 'normal! y'
        local search_text = vim.fn.getreg '"'
        vim.fn.setreg('"', old_reg, old_regtype)
        require('fff').live_grep()
        vim.schedule(function() vim.api.nvim_feedkeys(search_text, 'n', false) end)
      end,
      mode = 'v',
      desc = '[S]earch selected text (fff)',
    },
    { '<leader>sn', function() require('fff').find_files_in_dir(vim.fn.stdpath 'config') end, desc = '[S]earch [N]eovim files (fff)' },
  },
}
