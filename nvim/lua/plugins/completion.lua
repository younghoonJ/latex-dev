return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
        menu = { border = "rounded" },
      },
      signature = { enabled = true },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
