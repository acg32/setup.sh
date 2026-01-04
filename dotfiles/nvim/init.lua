vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.homepage")
require("config.lazy")

local local_init = vim.fn.stdpath("config") .. "/init.local.lua"
if vim.loop.fs_stat(local_init) then
  dofile(local_init)
end
