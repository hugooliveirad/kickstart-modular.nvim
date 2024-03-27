return {
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    config = function()
      require('typescript-tools').setup {
        settings = {
          separate_diagnostic_server = true,
          expose_as_code_action = 'all',
        },
      }
    end,
  },
}
