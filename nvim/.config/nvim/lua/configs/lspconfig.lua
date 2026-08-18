require("nvchad.configs.lspconfig").defaults()

local servers = {
  "asm_lsp",
  "autotools_ls",
  "clangd",
  "cssls",
  "gopls",
  "html",
  "jdtls",
  "ocamllsp",
  "pyright",
  "qmlls",
  -- "rust_analyzer"), -- already handled by rustaceanvim
  "shuck",
  "tinymist",
  "vhdl_ls",
  "vtsls",
}

vim.lsp.enable(servers)

vim.lsp.config("jdtls", {
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = "JavaSE-21",
            path = "/opt/jdk-21",
            default = true,
          },
        },
      },
    },
  },
})

-- read :h vim.lsp.config for changing options of lsp servers
