local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Bufferline navigation
-- Note: in many terminals, <Tab> and <C-i> are the same key code.
map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer", silent = true })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer", silent = true })
map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer", silent = true })
map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer", silent = true })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer", silent = true })
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close other buffers", silent = true })
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Pin/unpin buffer", silent = true })
