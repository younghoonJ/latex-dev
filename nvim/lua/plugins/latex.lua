return {
  {
    "lervag/vimtex",
    tag = "v2.18",
    lazy = false,
    init = function()
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_compiler_method = "latexmk"

      if vim.fn.has("win32") == 1 then
        -- Windows: MiKTeX + SumatraPDF
        vim.g.vimtex_view_method = "general"

        local sumatra = vim.g.nvim_latex_sumatra_path or vim.fn.exepath("SumatraPDF")
        if sumatra == "" then
          local candidates = {
            vim.fn.expand("$LOCALAPPDATA/SumatraPDF/SumatraPDF.exe"),
            vim.fn.expand("$LOCALAPPDATA/Programs/SumatraPDF/SumatraPDF.exe"),
            [[C:\Program Files\SumatraPDF\SumatraPDF.exe]],
          }
          for _, candidate in ipairs(candidates) do
            if vim.uv.fs_stat(candidate) then
              sumatra = candidate
              break
            end
          end
        end

        vim.g.vimtex_view_general_viewer = sumatra ~= "" and sumatra or "SumatraPDF"
        vim.g.vimtex_view_general_options = [[-reuse-instance -forward-search @tex @line @pdf]]
        vim.g.vimtex_view_general_options_latexmk = [[-reuse-instance]]
      elseif vim.env.NVIM_LATEX_PDF_VIEWER == "zathura" then
        if vim.env.XDG_SESSION_TYPE == "wayland" then
          vim.g.vimtex_view_method = "zathura_simple"
        else
          vim.g.vimtex_view_method = "zathura"
        end
      else
        -- Ubuntu default: Okular
        vim.g.vimtex_view_method = "general"
        vim.g.vimtex_view_general_viewer = "okular"
        vim.g.vimtex_view_general_options = [[--unique file:@pdf\#src:@line@tex]]
      end

      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_fold_enabled = 0
      vim.g.vimtex_syntax_conceal_disable = 1
      vim.g.vimtex_view_forward_search_on_start = 0
    end,
  },
}
