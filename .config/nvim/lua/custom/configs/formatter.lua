local M = {
  filetype = {
    javascript = {
      require("formatter.filetypes.javascript").prettier,
    },
    typescript = {
      require("formatter.filetypes.typescript").prettier,
    },
    typescriptreact = {
      require("formatter.filetypes.typescriptreact").prettier,
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
    py = {
      require("formatter.filetypes.python").black,
    },
    cpp = {
      require("formatter.filetypes.c").clangformat,
    },
    rust = {
      require("formatter.filetypes.rust").rustfmt,
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
