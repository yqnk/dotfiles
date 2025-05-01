local M = {
  filetype = {
    javascript = {
      require("formatter.filetypes.javascript").prettier,
    },
    typescript = {
      require("formatter.filetypes.typescript").prettier,
    },
    lua = {
      require("formatter.filetypes.lua").stylua,
    },
    go = {
      require("formatter.filetypes.go").gofmt,
      require("formatter.filetypes.go").goimports,
    },
    c = {
      require("formatter.filetypes.c").clangformat,
    },
    cpp = {
      require("formatter.filetypes.c").clangformat,
    },
    ["*"] = {
      require("formatter.filetypes.any").remove_trailing_whitespace,
    },
  },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  command = "FormatWriteLock",
})

return M
