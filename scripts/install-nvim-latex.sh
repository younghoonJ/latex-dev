#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib-install.sh"

SKIP_NEOVIM="${SKIP_NEOVIM:-0}"
SKIP_NVIM_PLUGINS="${SKIP_NVIM_PLUGINS:-0}"
PDF_VIEWER="${PDF_VIEWER:-okular}"

case "$PDF_VIEWER" in
  okular|zathura) ;;
  *) die "Neovim/VimTeX viewer는 PDF_VIEWER=okular 또는 PDF_VIEWER=zathura만 지원합니다." ;;
esac

require_apt_linux

install_neovim() {
  local machine nvim_arch archive_url tmpdir archive extracted install_dir
  machine="$(uname -m)"

  case "$machine" in
    x86_64|amd64) nvim_arch="x86_64" ;;
    aarch64|arm64) nvim_arch="arm64" ;;
    *) die "지원하지 않는 CPU 아키텍처입니다: $machine" ;;
  esac

  archive_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.tar.gz"
  tmpdir="$(mktemp -d)"
  archive="$tmpdir/nvim.tar.gz"
  extracted="$tmpdir/nvim-linux-${nvim_arch}"
  install_dir="/opt/nvim-linux-${nvim_arch}"

  log "최신 안정 Neovim 다운로드"
  curl --fail --location --retry 3 --output "$archive" "$archive_url"
  tar -xzf "$archive" -C "$tmpdir"
  [[ -x "$extracted/bin/nvim" ]] || die "Neovim 아카이브가 올바르지 않습니다."

  log "Neovim 설치: $install_dir"
  "${SUDO[@]}" rm -rf "$install_dir"
  "${SUDO[@]}" mv "$extracted" "$install_dir"
  "${SUDO[@]}" ln -sf "$install_dir/bin/nvim" /usr/local/bin/nvim
  hash -r
  rm -rf "$tmpdir"
}

configure_shell_path() {
  local rc marker_start marker_end
  marker_start="# >>> nvim-latex environment >>>"
  marker_end="# <<< nvim-latex environment <<<"

  mkdir -p "$HOME/.local/bin"

  for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    touch "$rc"
    sed -i "\|${marker_start}|,\|${marker_end}|d" "$rc"
    cat >> "$rc" <<'EOF_SHELL'

# >>> nvim-latex environment >>>
export PATH="$HOME/.local/bin:$HOME/.local/share/nvim/mason/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
# <<< nvim-latex environment <<<
EOF_SHELL
  done

  export PATH="$HOME/.local/bin:$HOME/.local/share/nvim/mason/bin:$PATH"
}

write_nvim_config() {
  local config_dir backup_dir timestamp
  config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  timestamp="$(date +%Y%m%d-%H%M%S)"

  if [[ -e "$config_dir" || -L "$config_dir" ]]; then
    backup_dir="${config_dir}.backup.${timestamp}"
    log "기존 Neovim 설정 백업: $backup_dir"
    mv "$config_dir" "$backup_dir"
  fi

  mkdir -p "$config_dir/lua/config" "$config_dir/lua/plugins"

  cat > "$config_dir/init.lua" <<'EOF_INIT'
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("config.options")
require("config.keymaps")
require("config.lazy")
EOF_INIT

  cat > "$config_dir/lua/config/options.lua" <<'EOF_OPTIONS'
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
EOF_OPTIONS

  cat > "$config_dir/lua/config/keymaps.lua" <<'EOF_KEYMAPS'
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
EOF_KEYMAPS

  cat > "$config_dir/lua/config/lazy.lua" <<'EOF_LAZY'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    error("Failed to install lazy.nvim:\n" .. output)
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  checker = { enabled = false },
  change_detection = { notify = false },
  install = { colorscheme = { "tokyonight", "habamax" } },
  ui = { border = "rounded" },
})
EOF_LAZY

  if [[ "$PDF_VIEWER" == "okular" ]]; then
    cat > "$config_dir/lua/plugins/latex.lua" <<'EOF_LATEX_OKULAR'
return {
  {
    "lervag/vimtex",
    tag = "v2.17",
    lazy = false,
    init = function()
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "okular"
      vim.g.vimtex_view_general_options = [[--unique file:@pdf\#src:@line@tex]]
      vim.g.vimtex_view_general_options_latexmk = [[--unique]]
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_fold_enabled = 0
      vim.g.vimtex_syntax_conceal_disable = 1
      vim.g.vimtex_view_forward_search_on_start = 0
    end,
  },
}
EOF_LATEX_OKULAR
  else
    cat > "$config_dir/lua/plugins/latex.lua" <<'EOF_LATEX_ZATHURA'
return {
  {
    "lervag/vimtex",
    tag = "v2.17",
    lazy = false,
    init = function()
      vim.g.vimtex_compiler_method = "latexmk"
      if vim.env.XDG_SESSION_TYPE == "wayland" then
        vim.g.vimtex_view_method = "zathura_simple"
      else
        vim.g.vimtex_view_method = "zathura"
      end
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_fold_enabled = 0
      vim.g.vimtex_syntax_conceal_disable = 1
      vim.g.vimtex_view_forward_search_on_start = 0
    end,
  },
}
EOF_LATEX_ZATHURA
  fi

  cat > "$config_dir/lua/plugins/completion.lua" <<'EOF_COMPLETION'
return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "default" },
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
EOF_COMPLETION

  cat > "$config_dir/lua/plugins/lsp.lua" <<'EOF_LSP'
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
EOF_LSP

  cat > "$config_dir/lua/plugins/navigation.lua" <<'EOF_NAVIGATION'
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
EOF_NAVIGATION

  cat > "$config_dir/lua/plugins/ui.lua" <<'EOF_UI'
return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "night" },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  { "folke/which-key.nvim", event = "VeryLazy", opts = { preset = "modern", delay = 350 } },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        separator_style = "thin",
        always_show_bufferline = true,
        show_close_icon = false,
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        section_separators = { left = "", right = "" },
      },
    },
  },
}
EOF_UI

  if [[ "$PDF_VIEWER" == "zathura" ]]; then
    local zathura_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zathura"
    local zathurarc="$zathura_dir/zathurarc"
    mkdir -p "$zathura_dir"
    touch "$zathurarc"
    sed -i "\|# >>> nvim-latex viewer >>>|,\|# <<< nvim-latex viewer <<<|d" "$zathurarc"
    cat >> "$zathurarc" <<'EOF_ZATHURA'

# >>> nvim-latex viewer >>>
set synctex true
set pages-per-row 1
set adjust-open "best-fit"
set window-title-basename true
# <<< nvim-latex viewer <<<
EOF_ZATHURA
  fi
}

install_plugins() {
  command -v nvim >/dev/null 2>&1 || die "nvim을 PATH에서 찾을 수 없습니다."
  log "Neovim plugin 및 TexLab 설치"
  nvim --headless "+Lazy! sync" +qa
  nvim --headless "+MasonToolsInstallSync" +qa
}

if [[ "$SKIP_NEOVIM" != "1" ]]; then
  install_neovim
else
  command -v nvim >/dev/null 2>&1 || die "SKIP_NEOVIM=1 이지만 nvim을 PATH에서 찾을 수 없습니다."
fi

configure_shell_path
write_nvim_config

if [[ "$SKIP_NVIM_PLUGINS" != "1" ]]; then
  install_plugins
else
  warn "Neovim plugin 설치를 건너뜁니다. 첫 실행 때 lazy.nvim이 설치합니다."
fi

ok "Neovim LaTeX 설정 완료"
