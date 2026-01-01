local function safe_require(module)
  local ok, loaded = pcall(require, module)
  if not ok then
    return nil
  end
  return loaded
end

return {
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      local onedark = safe_require("onedark")
      if not onedark then
        return
      end
      onedark.setup({ style = "darker" })
      onedark.load()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local lualine = safe_require("lualine")
      if not lualine then
        return
      end
      lualine.setup({
        options = {
          theme = "onedark",
          section_separators = "",
          component_separators = "",
        },
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = safe_require("gitsigns")
      if not gitsigns then
        return
      end
      gitsigns.setup()
    end,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      local comment = safe_require("Comment")
      if not comment then
        return
      end
      comment.setup()
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = safe_require("nvim-autopairs")
      if not autopairs then
        return
      end
      autopairs.setup()
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local which_key = safe_require("which-key")
      if not which_key then
        return
      end
      which_key.setup()
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    },
    config = function()
      local telescope = safe_require("telescope")
      if not telescope then
        return
      end
      telescope.setup({
        defaults = {
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      local treesitter = safe_require("nvim-treesitter.configs")
      if not treesitter then
        return
      end
      treesitter.setup({
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = {
          "bash",
          "css",
          "dockerfile",
          "html",
          "json",
          "lua",
          "markdown",
          "python",
          "regex",
          "toml",
          "typescript",
          "vim",
          "yaml",
        },
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    config = function()
      local mason = safe_require("mason")
      if not mason then
        return
      end
      mason.setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      local mason_lsp = safe_require("mason-lspconfig")
      if not mason_lsp then
        return
      end
      mason_lsp.setup({
        ensure_installed = {
          "bashls",
          "jsonls",
          "lua_ls",
          "pyright",
          "yamlls",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local lspconfig = safe_require("lspconfig")
      local cmp_lsp = safe_require("cmp_nvim_lsp")
      if not lspconfig or not cmp_lsp then
        return
      end
      local capabilities = cmp_lsp.default_capabilities()

      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gr", vim.lsp.buf.references, "References")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
      end

      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded" },
      })

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      for _, server in ipairs({ "bashls", "jsonls", "pyright", "yamlls" }) do
        lspconfig[server].setup({
          capabilities = capabilities,
          on_attach = on_attach,
        })
      end
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = safe_require("cmp")
      local luasnip = safe_require("luasnip")
      if not cmp or not luasnip then
        return
      end

      local luasnip_loader = safe_require("luasnip.loaders.from_vscode")
      if luasnip_loader then
        luasnip_loader.lazy_load()
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer" },
        }),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
          { name = "cmdline" },
        }),
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    config = function()
      local conform = safe_require("conform")
      if not conform then
        return
      end
      conform.setup({
        format_on_save = { lsp_fallback = true },
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_format" },
          sh = { "shfmt" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
        },
      })
    end,
  },
}
