local M = {}

function M:setup()
  local mason_path = vim.fn.stdpath "data" .. "/mason"
  local jdtls_path = mason_path .. "/packages/jdtls"
  local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  local lombok_jar = jdtls_path .. "/lombok.jar"
  local config_os = "config_linux"
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local workspace_dir = vim.fn.stdpath "data"
    .. package.config:sub(1, 1)
    .. "jdtls-workspace"
    .. package.config:sub(1, 1)
    .. project_name

  -- See `:help vim.lsp.start` for an overview of the supported `config` options.
  local config = {
    on_attach = function(client, bufnr)
      local function nvchad_on_attach(client, bufnr)
        require("nvchad.configs.lspconfig").on_attach(client, bufnr)
      end

      pcall(nvchad_on_attach, client, bufnr)

      client.server_capabilities.semanticTokensProvider = nil
    end,
    cmd = {
      "java", -- should be java 21
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xms1g",

      "-javaagent:" .. lombok_jar,

      "--add-modules=ALL-SYSTEM",
      "--add-opens",
      "java.base/java.util=ALL-UNNAMED",
      "--add-opens",
      "java.base/java.lang=ALL-UNNAMED",

      "-jar",
      launcher_jar,

      "-configuration",
      jdtls_path .. "/" .. config_os,
      "-data",
      workspace_dir,
    },

    root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },

    settings = {
      java = {},
    },
  }
  require("jdtls").start_or_attach(config)
end

return M
