local opt = vim.opt

opt.number = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.ignorecase = true
opt.smartcase = true
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.scrolloff = 5
opt.splitright = true
opt.splitbelow = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.laststatus = 3
opt.completeopt = { "menu", "menuone", "noselect" }
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.confirm = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex", "bib" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.textwidth = 0
  end,
})
