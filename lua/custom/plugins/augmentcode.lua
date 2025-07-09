return {
  {
    'augmentcode/augment.vim',
    config = function()
      vim.g.augment_workspace_folders = { '~/workspace' }
      
      -- Create a global variable to track augment state
      vim.g.augment_enabled = true
      
      -- Function to toggle augment on/off
      vim.api.nvim_create_user_command('AugmentToggle', function()
        if vim.g.augment_enabled then
          -- Disable augment by setting the disable flags
          vim.g.augment_disable_completions = true
          vim.g.augment_disable_tab_mapping = true
          vim.g.augment_enabled = false
          vim.notify('Augment disabled', vim.log.levels.INFO)
        else
          -- Enable augment by unsetting the disable flags
          vim.g.augment_disable_completions = false
          vim.g.augment_disable_tab_mapping = false
          vim.g.augment_enabled = true
          vim.notify('Augment enabled', vim.log.levels.INFO)
        end
      end, {})
    end,
  },
}
