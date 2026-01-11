require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    require("configs.jdtls").setup()
  end,
})
