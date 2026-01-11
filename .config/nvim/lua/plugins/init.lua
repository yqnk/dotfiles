return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      exclude = {
        "jdtls",
      },
    },
  },
  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "rust",
        "typescript",
        "go",
        "c",
        "cpp",
        "make",
        "cmake",
      },
    },
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^6", -- Recommended
    lazy = false, -- This plugin is already lazy
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup()
    end,
  },

  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },

  { "Civitasv/cmake-tools.nvim", opts = {}, ft = { "c", "cpp", "c++", "cc" } },
}
