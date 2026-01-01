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
