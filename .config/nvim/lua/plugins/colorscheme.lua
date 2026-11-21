return {
  {
    "Senal-D-A-Gunaratna/matugen.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      load_theme = true,
      palette_path = "~/.config/nvim/templates/nvim-colors.json",
    },
    config = function(_, opts)
      local matugen = require("matugen")
      matugen.setup(opts)
      matugen.load_theme()
      vim.g.colors_name = "matugen"

      -- Set transparency after a short delay to override matugen
      vim.defer_fn(function()
        vim.cmd([[
          highlight CursorLine guibg=NONE
          highlight Normal guibg=NONE
          highlight NormalFloat guibg=NONE
          highlight SignColumn guibg=NONE
          highlight LineNr guibg=NONE
        ]])
        print("✓ Matugen loaded with transparency!")
      end, 300)

      -- Live-reload the palette when matugen regenerates it on disk
      vim.g.matugen_mtime = vim.fn.getftime(vim.fn.expand("~/.config/nvim/templates/nvim-colors.json"))
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          local palette = vim.fn.expand("~/.config/nvim/templates/nvim-colors.json")
          local mtime = vim.fn.getftime(palette)
          if mtime < 0 or mtime == vim.g.matugen_mtime then
            return
          end
          vim.g.matugen_mtime = mtime
          require("matugen").load_theme()
          vim.g.colors_name = "matugen"
          vim.cmd([[
            highlight CursorLine guibg=NONE
            highlight Normal guibg=NONE
            highlight NormalFloat guibg=NONE
            highlight SignColumn guibg=NONE
            highlight LineNr guibg=NONE
          ]])
        end,
      })
    end,
  },
}
