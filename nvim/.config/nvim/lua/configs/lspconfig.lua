require("nvchad.configs.lspconfig").defaults()

local servers = {
  "asm_lsp",
  "autotools_ls",
  "clangd",
  "cmake",
  "cssls",
  "gopls",
  "html",
  "jdtls",
  "nil_ls",
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

vim.lsp.config("shuck", {
  cmd = { "shuck", "server" },
  filetypes = { "sh", "bash", "zsh" },
})

-- read :h vim.lsp.config for changing options of lsp servers
