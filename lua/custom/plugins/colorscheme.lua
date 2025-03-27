return {
  -- {
  --   'ellisonleao/gruvbox.nvim',
  --   priority = 1000,
  --   config = function()
  --     local gruvbox = require 'gruvbox'
  --     gruvbox.setup {
  --       transparent_mode = true,
  --       bold = false,
  --       overrides = {
  --         LspReferenceRead = { bg = gruvbox.palette.dark2 },
  --         LspReferenceText = { bg = gruvbox.palette.dark2 },
  --         LspReferenceWrite = { bg = gruvbox.palette.dark2 },
  --         Cursor = { fg = gruvbox.palette.dark3, bg = gruvbox.palette.dark3 },
  --         iCursor = { fg = gruvbox.palette.dark4, bg = gruvbox.palette.dark4 },
  --       },
  --     }

  --     vim.o.guicursor = 'n-v-c-sm:block,i-ci-ve:block-iCursor,r-cr-o:block-iCursor'
  --     vim.cmd 'colorscheme gruvbox'
  --   end,
  -- },
  -- {
  --   'morhetz/gruvbox',
  --   priority = 1000,
  --   config = function()
  --     vim.cmd 'let g:gruvbox_contrast_dark="medium"'
  --     vim.cmd 'let g:gruvbox_sign_column="bg0"'
  --     vim.cmd 'let g:gruvbox_bold=0'
  --     vim.cmd 'let g:gruvbox_invert_selection=0'
  --     vim.cmd 'colorscheme gruvbox'
  --   end,
  -- },
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`
    'folke/tokyonight.nvim',
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {
      transparent = true,
    },
    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-moon'

      -- You can configure highlights by doing something like
      vim.cmd.hi 'Comment gui=none'
    end,
  },

  {
    'vigoux/oak',
    priority = 1000,
    init = function()
      -- vim.cmd.colorscheme 'oak'

      -- You can configure highlights by doing something like
      -- vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'savq/melange-nvim',
    priority = 1000,
    init = function()
      -- vim.opt.termguicolors = true
      -- vim.cmd.colorscheme 'melange'
      -- vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'ellisonleao/gruvbox.nvim',

    priority = 1000,
    init = function()
      -- vim.opt.termguicolors = true
      -- vim.cmd.colorscheme 'gruvbox'
      -- vim.cmd.hi 'Comment gui=none'
    end,
  },
}
