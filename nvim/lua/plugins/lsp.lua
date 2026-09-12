return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    opts = { PATH = "prepend", ui = { border = "rounded" } },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim" },
    opts = { ensure_installed = { "texlab" }, auto_update = false, run_on_start = false },
  },
  {
    "neovim/nvim-lspconfig",
    ft = { "tex", "plaintex", "bib" },
    dependencies = { "mason-org/mason.nvim", "saghen/blink.cmp" },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("texlab", {
        capabilities = capabilities,
        settings = { texlab = { build = { onSave = false }, diagnosticsDelay = 300 } },
      })
      vim.lsp.enable("texlab")
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        virtual_text = true,
        signs = true,
        underline = true,
      })
    end,
  },
}
