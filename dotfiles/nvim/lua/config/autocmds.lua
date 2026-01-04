local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local trim_group = augroup("TrimTrailingWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = trim_group,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

vim.filetype.add({
  extension = {
    s3cfg = "dosini",
    ghci = "haskell",
  },
  filename = {
    [".ghci"] = "haskell",
    [".aws/credentials"] = "dosini",
  },
  pattern = {
    ["env%.dist.*"] = "sh",
    [".*%.ini%.template"] = "dosini",
    [".*%.yml%.template"] = "yaml",
    ["nginx.*%.conf"] = "nginx",
    ["%.X.*"] = "xdefaults",
  },
})

local sql_group = augroup("SqlCommentString", { clear = true })
autocmd("FileType", {
  group = sql_group,
  pattern = "sql",
  callback = function()
    vim.opt_local.commentstring = "-- %s"
  end,
})

local number_group = augroup("EnableLineNumbers", { clear = true })
autocmd({ "BufEnter", "BufWinEnter" }, {
  group = number_group,
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
    if vim.bo.filetype == "homepage" then
      return
    end
    vim.wo.number = true
    vim.wo.relativenumber = false
  end,
})

local tree_group = augroup("NeoTreeOnDir", { clear = true })
autocmd("VimEnter", {
  group = tree_group,
  callback = function()
    if vim.fn.argc() ~= 1 then
      return
    end
    local dir = vim.fn.argv(0)
    if vim.fn.isdirectory(dir) ~= 1 then
      return
    end
    vim.cmd("cd " .. vim.fn.fnameescape(dir))
    local ok, neotree = pcall(require, "neo-tree.command")
    if ok then
      neotree.execute({ action = "focus", source = "filesystem", position = "left" })
    end
  end,
})
