return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files({ hidden = true }) end, desc = "Find files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Search project text" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Find buffers" },
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", function() require("nvim-tree.api").tree.toggle({ focus = true }) end, desc = "Toggle file tree" },
      { "<leader>E", function() require("nvim-tree.api").tree.find_file({ open = true, focus = true }) end, desc = "Find current file in tree" },
    },
    opts = {
      sync_root_with_cwd = true,
      view = { side = "left", width = 32 },
      filters = { dotfiles = false, custom = { "^\\.git$" } },
    },
  },
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory" } },
    opts = { default_file_explorer = false, view_options = { show_hidden = true } },
  },
}
