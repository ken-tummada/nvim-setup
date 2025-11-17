-- Basic Editor Settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.termguicolors = true
vim.o.completeopt = "menu,menuone,noselect"  -- good for completion popup
vim.o.lazyredraw = true
vim.o.ttyfast = true

vim.opt.spell = true
vim.opt.spelllang = { "en_us" }

vim.g.mapleader = " "  -- make Space your leader key

-- Plugin Manager (lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP config
  {"neovim/nvim-lspconfig"},

  -- Autocomplete engine + sources
  {"hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",         -- snippet engine
      "saadparwaiz1/cmp_luasnip",
    }
  },

  -- Treesitter (better syntax highlighting)
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},

  -- File explorer
  {"nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" }},

  -- Fuzzy finder
  {"nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }},

  -- Theme (optional)
  {"catppuccin/nvim", name = "catppuccin"},

  -- Statusline
  {"nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }},

  -- Oil
  {"stevearc/oil.nvim", opts = {}, dependencies = { "nvim-tree/nvim-web-devicons" }},

  { "windwp/nvim-autopairs" },
  { "sainnhe/sonokai" },

  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = true
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
        automatic_enable = false,
    },
  },

  {
    "hrsh7th/nvim-cmp", dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
      },
   }
})

-- Theme
vim.cmd.colorscheme "sonokai"
vim.g.sonokai_style = "andromeda"

-- Keybindings for some features
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>", { silent = true })
vim.keymap.set("n", "<C-f>", ":Telescope live_grep<CR>", { silent = true })

-- Setup LSP servers

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "clangd", "lua_ls", "typos_lsp" },
})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
end

lspconfig.typos_lsp.setup({})
lspconfig.pyright.setup({
    capabilities = capabilities,
    on_attach = on_attach
})
lspconfig.clangd.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    init_options = {
        fallbackFlags = { "-std=c++20", "-Iinclude" }
    },
})
lspconfig.lua_ls.setup({
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
    },
  },
})

vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.open_float(nil, { focus = false })
end, { desc = "Show diagnostics in float" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })


require("nvim-autopairs").setup({})

-- Setup nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  },
})

require("nvim-treesitter.configs").setup {
  ensure_installed = { "cpp", "c", "lua", "python" },  -- include C++ etc
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

require("oil").setup({
  -- optionally override defaults
  default_file_explorer = true,
  columns = { "icon", "size", "mtime" },
  keymaps = {
    ["<CR>"] = "actions.select",
    ["-"]    = "actions.parent",
  },
  constrain_cursor="name",
})

-- keymap to open oil at current directory
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory / file explorer" })
