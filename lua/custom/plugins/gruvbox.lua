return {
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      require('gruvbox').setup {
        bold = false,
        undercurl = false,
        underline = false,
        invert_selection = false,
        inverse = false,
        contrast = 'hard',
        overrides = {
          SignColumn = { bg = '#282828' },
        },
      }

      vim.o.background = 'dark' -- or "light" for light mode
      vim.cmd [[colorscheme gruvbox]]
    end,
  },
}
