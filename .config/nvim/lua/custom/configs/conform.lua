local M = {}

M.opts = {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = { c = false, s = true, cpp = false }
    return {
      timeout_ms = 500,
      lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
    }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    js = { "prettier" },
    ts = { "prettier" },
    go = { "goimports", "gofmt" },
    mojo = { "mojo" },
  },
  formatters = {
    mojo = {
      command = "mojo",
      args = { "format", "-" },
      stdin = true,
    },
  },
}

M.keys = {
  {
    "<leader>f",
    function()
      require("conform").format { async = true, lsp_fallback = true }
    end,
    mode = "",
    desc = "[F]ormat buffer",
  },
}

return M
