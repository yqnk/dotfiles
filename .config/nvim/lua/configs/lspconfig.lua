require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "jdtls", "pyright", "clangd", "vtsls" }
vim.lsp.enable(servers)

vim.lsp.config('jdtls', {
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = "JavaSE-21",
            path = "/opt/jdk-21",
            default = true,
          }
        }
      }
    }
  }
})
-- read :h vim.lsp.config for changing options of lsp servers 
