vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- On Windows, expose a stable RPC pipe for SumatraPDF inverse SyncTeX.
if vim.fn.has("win32") == 1 then
  local inverse_pipe = "//./pipe/nvim-latex"
  local ok, err = pcall(vim.fn.serverstart, inverse_pipe)
  if not ok then
    vim.schedule(function()
      vim.notify("Inverse SyncTeX RPC server: " .. tostring(err), vim.log.levels.WARN)
    end)
  end
end

pcall(require, "config.viewer")
require("config.options")
require("config.keymaps")
require("config.lazy")
