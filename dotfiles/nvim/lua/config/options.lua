local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.colorcolumn = "100"
opt.signcolumn = "yes"
opt.splitright = true
opt.splitbelow = true
opt.wrap = false
opt.scrolloff = 5
opt.sidescrolloff = 5
opt.showmode = false
opt.termguicolors = true
opt.background = "dark"
opt.updatetime = 300
opt.timeoutlen = 400

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

opt.clipboard = "unnamedplus"
opt.undofile = true

opt.completeopt = { "menu", "menuone", "noselect" }

local undo_dir = vim.fn.stdpath("state") .. "/undo"
if vim.fn.isdirectory(undo_dir) == 0 then
  vim.fn.mkdir(undo_dir, "p")
end
opt.undodir = undo_dir
