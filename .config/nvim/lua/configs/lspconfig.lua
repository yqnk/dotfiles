require("nvchad.configs.lspconfig").defaults()

-- jdtls enabled through autocmds
local servers = { "html", "cssls", "rust_analyzer", "clangd", "vtsls", "gopls", "pyright" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
