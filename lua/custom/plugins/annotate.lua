-- annotate.nvim - Code review annotations with virtual text display
-- https://github.com/hugooliveirad/annotate.nvim

return {
  "hugooliveirad/annotate.nvim",
  opts = {},
  keys = {
    { "<leader>ra", mode = "v", desc = "[R]eview: [A]dd annotation" },
    { "<leader>rl", desc = "[R]eview: [L]ist annotations" },
    { "<leader>rs", desc = "[R]eview: [S]earch annotations (Telescope)" },
    { "<leader>ry", desc = "[R]eview: [Y]ank all annotations" },
    { "<leader>rd", desc = "[R]eview: [D]elete annotation" },
    { "<leader>re", desc = "[R]eview: [E]dit annotation" },
    { "<leader>rD", desc = "[R]eview: Delete all annotations" },
    { "<leader>ru", desc = "[R]eview: [U]ndo delete" },
    { "<leader>rU", desc = "[R]eview: Redo delete" },
    { "<leader>rw", desc = "[R]eview: [W]rite to file" },
    { "<leader>ri", desc = "[R]eview: [I]mport from file" },
    { "]r", desc = "Next annotation" },
    { "[r", desc = "Previous annotation" },
  },
  cmd = { "Annotate", "AnnotateAdd", "AnnotateList", "AnnotateTelescope", "AnnotateDelete", "AnnotateEdit" },
}
