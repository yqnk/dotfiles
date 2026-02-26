vim.g.rustaceanvim = {
  server = {
    settings = {
      ["rust-analyzer"] = {
        rustfmt = {
          extraArgs = { "+nightly", "--unstable-features" },
        },
      },
    },
  },
}
