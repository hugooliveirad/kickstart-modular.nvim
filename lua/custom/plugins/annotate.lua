-- annotate.nvim - Code review annotations with virtual text display
-- https://github.com/hugooliveirad/annotate.nvim

return {
  "hugooliveirad/annotate.nvim",
  opts = {},
  config = function(_, opts)
    require("annotate").setup(opts)
    require("annotate").set_keymaps()
  end,
}
