-- local M = {}
-- local map = vim.keymap.set
--
-- -- export on_attach & capabilities
-- M.on_attach = function(_, bufnr)
--   local function opts(desc)
--     return { buffer = bufnr, desc = "LSP " .. desc }
--   end
--
--   map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
--   map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
--   map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
--   map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
--
--   map("n", "<leader>wl", function()
--     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
--   end, opts "List workspace folders")
--
--   map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
--   map("n", "<leader>ra", require "nvchad.lsp.renamer", opts "NvRenamer")
-- end
--
-- -- disable semanticTokens
-- M.on_init = function(client, _)
--   if vim.fn.has "nvim-0.11" ~= 1 then
--     if client.supports_method "textDocument/semanticTokens" then
--       client.server_capabilities.semanticTokensProvider = nil
--     end
--   else
--     if client:supports_method "textDocument/semanticTokens" then
--       client.server_capabilities.semanticTokensProvider = nil
--     end
--   end
-- end
--
-- M.capabilities = vim.lsp.protocol.make_client_capabilities()
--
-- M.capabilities.textDocument.completion.completionItem = {
--   documentationFormat = { "markdown", "plaintext" },
--   snippetSupport = true,
--   preselectSupport = true,
--   insertReplaceSupport = true,
--   labelDetailsSupport = true,
--   deprecatedSupport = true,
--   commitCharactersSupport = true,
--   tagSupport = { valueSet = { 1 } },
--   resolveSupport = {
--     properties = {
--       "documentation",
--       "detail",
--       "additionalTextEdits",
--     },
--   },
-- }
--
-- M.defaults = function()
--   dofile(vim.g.base46_cache .. "lsp")
--   require("nvchad.lsp").diagnostic_config()
--
--   vim.api.nvim_create_autocmd("LspAttach", {
--     callback = function(args)
--       M.on_attach(_, args.buf)
--     end,
--   })
--
--   local lua_lsp_settings = {
--     Lua = {
--       runtime = { version = "LuaJIT" },
--       workspace = {
--         library = {
--           vim.fn.expand "$VIMRUNTIME/lua",
--           vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
--           vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
--           "${3rd}/luv/library",
--         },
--       },
--     },
--   }
--
--   local go_lsp_settings = {
--     gopls = {
--       completeUnimported = true,
--     },
--   }
--
--   local configs = {
--     Lua = {
--       name = "lua_ls",
--       options = { settings = lua_lsp_settings },
--     },
--     TypeScript = {
--       name = "ts_ls",
--       options = {},
--     },
--     Go = {
--       name = "gopls",
--       options = {
--         cmd = { "gopls" },
--         filetypes = { "go", "gomod", "gowork", "gotmpl" },
--         root_dir = lsputil.root_pattern("go.work", "go.mod", ".git"),
--         settings = go_lsp_settings,
--       },
--     },
--   }
--
--   -- Support 0.10 temporarily
--
--   if vim.lsp.config then
--     vim.lsp.config("*", { capabilities = M.capabilities, on_init = M.on_init })
--
--     for i = 1, #configs do
--       vim.lsp.config(configs[i].name, configs[i].options)
--       vim.lsp.enable(configs[i].name)
--     end
--   else
--     require("lspconfig").lua_ls.setup {
--       capabilities = M.capabilities,
--       on_init = M.on_init,
--       settings = lua_lsp_settings,
--     }
--   end
-- end
--
-- return M
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

lspconfig.mojo.setup {
  on_init = M.on_init,
  on_attach = M.on_attach,
  capabilities = M.capabilities,

  cmd = { "mojo-lsp-server" },
  filetypes = { "mojo" },
  root_dir = function(fname)
    return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
  end,
  single_file_support = true,
}

lspconfig.clangd.setup {
  on_init = M.on_init,
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

lspconfig.pyright.setup {
  on_init = M.on_init,
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

lspconfig.cmake.setup {
  on_init = M.on_init,
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

return M
