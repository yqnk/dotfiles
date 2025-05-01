dofile(vim.g.base46_cache .. "lsp")
require "nvchad.lsp"

local M = {}
local utils = require "core.utils"
local lspconfig = require "lspconfig"
local lsputil = require "lspconfig/util"

-- export on_attach & capabilities for custom lspconfigs
M.on_attach = function(client, bufnr)
  utils.load_mappings("lspconfig", { buffer = bufnr })

  if client.server_capabilities.signatureHelpProvider then
    require("nvchad.signature").setup(client)
  end
end

-- disable semantic tokens
M.on_init = function(client, _)
  if not utils.load_config().ui.lsp_semantic_tokens and client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

lspconfig.lua_ls.setup {
  on_init = M.on_init,
  on_attach = M.on_attach,
  capabilities = M.capabilities,

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          [vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types"] = true,
          [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

lspconfig.ts_ls.setup {
  on_init = M.on_init,
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

lspconfig.gopls.setup {
  on_init = M.on_init,
  on_attach = M.on_attach,
  capabilities = M.capabilities,

  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = lsputil.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      analyses = {
        unusedParameters = true,
      },
    },
  },
}

lspconfig.clangd.setup {
  on_init = M.on_init,
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

return M
