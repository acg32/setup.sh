local M = {}

local ns = vim.api.nvim_create_namespace("Homepage")
local header_cache = nil
local ansi_hl_cache = {}

local function cmd_out(args)
  local output = vim.fn.systemlist(args)
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return output
end

local function repo_root()
  if vim.fn.executable("git") == 1 then
    local root = cmd_out({ "git", "rev-parse", "--show-toplevel" })
    if root and root[1] and root[1] ~= "" then
      return root[1]
    end
  end
  return vim.fn.getcwd()
end

local function git_status_line(root)
  if vim.fn.executable("git") ~= 1 then
    return nil
  end

  local inside = cmd_out({ "git", "-C", root, "rev-parse", "--is-inside-work-tree" })
  if not inside or inside[1] ~= "true" then
    return nil
  end

  local status = cmd_out({ "git", "-C", root, "status", "--porcelain=1", "-b" })
  if not status or #status == 0 then
    return nil
  end

  local head = status[1]
  local branch = head:match("^## ([^%.]+)") or head:match("^## ([^ ]+)") or "detached"
  local ahead = head:match("ahead (%d+)")
  local behind = head:match("behind (%d+)")
  local dirty = #status - 1

  local sync = {}
  if ahead then
    table.insert(sync, "↑" .. ahead)
  end
  if behind then
    table.insert(sync, "↓" .. behind)
  end

  local sync_text = #sync > 0 and (" " .. table.concat(sync, " ")) or ""
  local dirty_text = dirty > 0 and (" +" .. dirty) or " clean"
  return string.format("  %s%s%s", branch, sync_text, dirty_text)
end

local function git_log_lines(root)
  if vim.fn.executable("git") ~= 1 then
    return { "  git log: git not installed" }
  end

  local inside = cmd_out({ "git", "-C", root, "rev-parse", "--is-inside-work-tree" })
  if not inside or inside[1] ~= "true" then
    return { "  git log: not a repo" }
  end

  local log = cmd_out({
    "git",
    "-C",
    root,
    "log",
    "--pretty=format:%cr|%s",
    "-n",
    "5",
  })
  if not log or #log == 0 then
    return { "  git log: empty" }
  end

  local lines = {}
  for _, entry in ipairs(log) do
    local time, subject = entry:match("^(.-)|(.+)$")
    if not time then
      time = entry
      subject = ""
    end
    if subject == "" then
      table.insert(lines, "• " .. time)
    else
      table.insert(lines, string.format("• %s | %s", time, subject))
    end
  end
  return lines
end

local function workspace_stats_lines(root)
  local lines = {}
  local file_count = nil

  if vim.fn.executable("rg") == 1 then
    local files = cmd_out({ "rg", "--files", "--hidden", "--glob", "!.git/*", root })
    if files then
      local function extension_from_path(path)
        local name = path:match("([^/]+)$") or path
        local dot = name:find("%.[^%.]*$")
        if not dot or dot == 1 then
          return nil
        end
        return name:sub(dot + 1):lower()
      end

      local ext_counts = {}
      for _, path in ipairs(files) do
        local ext = extension_from_path(path)
        if ext and ext ~= "" then
          ext_counts[ext] = (ext_counts[ext] or 0) + 1
        end
      end

      file_count = #files
      local ext_list = {}
      for ext, count in pairs(ext_counts) do
        table.insert(ext_list, { ext = ext, count = count })
      end
      table.sort(ext_list, function(a, b)
        if a.count == b.count then
          return a.ext < b.ext
        end
        return a.count > b.count
      end)

      local top = {}
      for i = 1, math.min(3, #ext_list) do
        local pct = math.floor((ext_list[i].count / file_count) * 100 + 0.5)
        table.insert(top, string.format("%s %d%%", ext_list[i].ext, pct))
      end

      local ext_summary = #top > 0 and (" (" .. table.concat(top, ", ") .. ")") or ""
      table.insert(lines, string.format("  files: %d%s", file_count, ext_summary))
    end
  end

  return lines
end

local function readme_preview_lines(root)
  local candidates = {
    root .. "/README.md",
    root .. "/README.txt",
    root .. "/README",
  }
  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      local lines = vim.fn.readfile(path, "", 3)
      if lines and #lines > 0 then
        local preview = { "󰂺  README" }
        for _, line in ipairs(lines) do
          if line == "" then
            table.insert(preview, "  ")
          else
            table.insert(preview, "  " .. line)
          end
        end
        return preview
      end
    end
  end
  return { "󰂺  README: not found" }
end

local function calendar_lines()
  local now = os.date("*t")
  local year = now.year
  local month = now.month
  local first_day = os.date("*t", os.time({ year = year, month = month, day = 1 }))
  local start_wday = first_day.wday -- 1 = Sunday
  local days_in_month = os.date("*t", os.time({ year = year, month = month + 1, day = 0 })).day

  local lines = {}
  table.insert(lines, os.date("%B %Y"))
  table.insert(lines, "Su Mo Tu We Th Fr Sa")

  local line = {}
  for _ = 1, start_wday - 1 do
    table.insert(line, "  ")
  end

  for day = 1, days_in_month do
    table.insert(line, string.format("%2d", day))
    if #line == 7 then
      table.insert(lines, table.concat(line, " "))
      line = {}
    end
  end

  if #line > 0 then
    while #line < 7 do
      table.insert(line, "  ")
    end
    table.insert(lines, table.concat(line, " "))
  end

  return lines
end

local function default_header()
  return {
    "_.oo.                                          ",
    "                 _.u[[/;:,.         .odMMMMMM' ",
    "              .o888UU[[[/;:-.  .o@P^    MMM^   ",
    "             oN88888UU[[[/;::-.        dP^     ",
    "            dNMMNN888UU[[[/;:--.   .o@P^       ",
    "           ,MMMMMMN888UU[[/;::-. o@^           ",
    "           NNMMMNN888UU[[[/~.o@P^              ",
    "           888888888UU[[[/o@^-..               ",
    "          oI8888UU[[[/o@P^:--..                ",
    "       .@^  YUU[[[/o@^;::---..                 ",
    "     oMP     ^/o@P^;:::---..                   ",
    "  .dMMM    .o@^ ^;::---...                     ",
    " dMMMMMMM@^`       `^^^^                       ",
    "YMMMUP^                                        ",
    " ^^                                            ",
    "                                               ",
  }
end

local function hl_group_for_ansi(state, force_fg)
  local fg_source = force_fg or state.fg
  local fg = fg_source and string.format("%02x%02x%02x", fg_source[1], fg_source[2], fg_source[3]) or "none"
  local bg = state.bg and string.format("%02x%02x%02x", state.bg[1], state.bg[2], state.bg[3]) or "none"
  local bold = state.bold and "b" or "n"
  local key = fg .. "_" .. bg .. "_" .. bold
  local name = ansi_hl_cache[key]
  if name then
    return name
  end

  name = "HomepageAnsi_" .. key
  ansi_hl_cache[key] = name
  vim.api.nvim_set_hl(0, name, {
    fg = fg_source and string.format("#%s", fg) or nil,
    bg = state.bg and string.format("#%s", bg) or nil,
    bold = state.bold or nil,
  })
  return name
end

local function parse_ansi_line(line)
  local esc = "␛"
  local segments = {}
  local spans = {}
  local byte_index = 0
  local state = { fg = nil, bg = nil, bold = false }

  local function add_text(text)
    if text == "" then
      return
    end
    table.insert(segments, text)
    local width = #text
    local force_fg = nil
    if not state.fg and state.bg and text:find("%S") then
      force_fg = state.bg
    end
    local hl = hl_group_for_ansi(state, force_fg)
    table.insert(spans, { start = byte_index, finish = byte_index + width, group = hl })
    byte_index = byte_index + width
  end

  local idx = 1
  while idx <= #line do
    local esc_pos = line:find(esc .. "[", idx, true)
    if not esc_pos then
      add_text(line:sub(idx))
      break
    end

    if esc_pos > idx then
      add_text(line:sub(idx, esc_pos - 1))
    end

    local seq_end = line:find("m", esc_pos + 2, true)
    if not seq_end then
      add_text(line:sub(esc_pos))
      break
    end

    local seq = line:sub(esc_pos + 2, seq_end - 1)
    local nums = {}
    for num in seq:gmatch("%d+") do
      table.insert(nums, tonumber(num))
    end

    local i = 1
    while i <= #nums do
      local code = nums[i]
      if code == 0 then
        state.fg = nil
        state.bg = nil
        state.bold = false
        i = i + 1
      elseif code == 1 then
        state.bold = true
        i = i + 1
      elseif code == 22 then
        state.bold = false
        i = i + 1
      elseif code == 39 then
        state.fg = nil
        i = i + 1
      elseif code == 49 then
        state.bg = nil
        i = i + 1
      elseif code == 38 and nums[i + 1] == 2 then
        state.fg = { nums[i + 2], nums[i + 3], nums[i + 4] }
        i = i + 5
      elseif code == 48 and nums[i + 1] == 2 then
        state.bg = { nums[i + 2], nums[i + 3], nums[i + 4] }
        i = i + 5
      else
        i = i + 1
      end
    end

    idx = seq_end + 1
  end

  return table.concat(segments, ""), spans
end

local function load_header_lines()
  if header_cache then
    return header_cache
  end

  local source = debug.getinfo(1, "S").source
  local script_dir = vim.fn.fnamemodify(source:sub(2), ":h")
  local header_path = script_dir .. "/carina-nebula.txt"

  if vim.fn.filereadable(header_path) == 1 then
    local raw = vim.fn.readfile(header_path)
    local cleaned = {}
    local spans = {}
    for _, line in ipairs(raw) do
      local stripped, line_spans = parse_ansi_line(line)
      table.insert(cleaned, stripped)
      table.insert(spans, line_spans)
    end
    if #cleaned > 0 then
      header_cache = { lines = cleaned, spans = spans }
      return header_cache
    end
  end

  header_cache = { lines = default_header() }
  return header_cache
end

local function build_header()
  return load_header_lines()
end

local function menu_entries()
  return {
    { key = "f", icon = "", desc = "Find file", action = "Telescope find_files" },
    { key = "n", icon = "", desc = "New file", action = "ene | startinsert" },
    { key = "r", icon = "", desc = "Recent files", action = "Telescope oldfiles" },
    { key = "g", icon = "", desc = "Live grep", action = "Telescope live_grep" },
    { key = "t", icon = "", desc = "Neo-tree", action = "Neotree toggle" },
    { key = "c", icon = "", desc = "Config", action = "edit $MYVIMRC" },
    { key = "q", icon = "", desc = "Quit", action = "qa" },
  }
end

local function center_lines(lines, width, meta)
  local centered = {}
  local function shift_spans(spans, offset)
    if not spans or offset == 0 then
      return spans
    end
    local shifted = {}
    for _, span in ipairs(spans) do
      table.insert(shifted, {
        start = span.start + offset,
        finish = span.finish + offset,
        group = span.group,
      })
    end
    return shifted
  end

  local menu_width = nil
  if meta and meta.menu_lines then
    for line_nr, _ in pairs(meta.menu_lines) do
      local line = lines[line_nr]
      if line then
        local line_width = vim.fn.strdisplaywidth(line)
        menu_width = math.max(menu_width or 0, line_width)
      end
    end
  end

  for idx, line in ipairs(lines) do
    local line_width = vim.fn.strdisplaywidth(line)
    local padding = 0
    if meta and meta.menu_lines[idx] and menu_width and width > menu_width then
      padding = math.floor((width - menu_width) / 2)
    elseif width > line_width then
      padding = math.floor((width - line_width) / 2)
    end

    if padding > 0 then
      table.insert(centered, string.rep(" ", padding) .. line)
      if meta and meta.header_spans and idx <= meta.header_lines then
        meta.header_spans[idx] = shift_spans(meta.header_spans[idx], padding)
      end
    else
      table.insert(centered, line)
    end
  end
  return centered
end

local function render_lines(width)
  local header = build_header()
  local cal = calendar_lines()
  local root = repo_root()
  local cwd = vim.fn.fnamemodify(root, ":~")
  local timestamp = os.date("%Y-%m-%d %H:%M")
  local git_line = git_status_line(root)
  local git_log = git_log_lines(root)
  local stats = workspace_stats_lines(root)
  local readme = readme_preview_lines(root)

  local lines = {}
  local meta = {
    header_lines = #header.lines,
    header_spans = header.spans and vim.deepcopy(header.spans) or nil,
    calendar_start = nil,
    menu_lines = {},
  }

  for _, line in ipairs(header.lines) do
    table.insert(lines, line)
  end

  table.insert(lines, "")
  table.insert(lines, "  " .. cwd)
  table.insert(lines, "󰃭  " .. timestamp)
  table.insert(lines, "  " .. cal[1])

  table.insert(lines, cal[2])
  meta.calendar_start = #lines + 1
  for i = 3, #cal do
    table.insert(lines, cal[i])
  end

  table.insert(lines, "")

  local left_block = {}
  if git_line then
    table.insert(left_block, git_line)
  else
    table.insert(left_block, "  not a git repo")
  end
  for _, entry in ipairs(git_log) do
    table.insert(left_block, entry)
  end

  local right_block = {}
  for _, entry in ipairs(stats) do
    table.insert(right_block, entry)
  end
  for _, entry in ipairs(readme) do
    table.insert(right_block, entry)
  end

  local col_width_left = 0
  for _, entry in ipairs(left_block) do
    col_width_left = math.max(col_width_left, vim.fn.strdisplaywidth(entry))
  end
  local col_width_right = 0
  for _, entry in ipairs(right_block) do
    col_width_right = math.max(col_width_right, vim.fn.strdisplaywidth(entry))
  end

  local inner_pad = 1

  local function pad_left(text, width)
    local text_width = vim.fn.strdisplaywidth(text)
    local padded = string.rep(" ", inner_pad) .. text
    local padded_width = vim.fn.strdisplaywidth(padded)
    if width <= text_width then
      return padded
    end
    if padded_width < width + inner_pad then
      padded = padded .. string.rep(" ", width + inner_pad - padded_width)
    end
    return padded
  end

  local row_count = math.max(#left_block, #right_block)
  for i = 1, row_count do
    local left = pad_left(left_block[i] or "", col_width_left)
    local right = pad_left(right_block[i] or "", col_width_right)
    local gap = right ~= "" and "    " or ""
    local line = left .. gap .. right
    table.insert(lines, line)
  end

  table.insert(lines, "")
  table.insert(lines, "Stay curious. Ship small. Repeat.")
  table.insert(lines, "──── info ────────────────────────────────────")
  table.insert(lines, "")

  local menu = menu_entries()
  for _, item in ipairs(menu) do
    local line = string.format("[%s] %s  %s", item.key, item.icon, item.desc)
    table.insert(lines, line)
    meta.menu_lines[#lines] = item
  end

  return center_lines(lines, width, meta), meta
end

local function apply_highlights(bufnr, meta)
  local function resolve_group(candidates, fallback)
    for _, name in ipairs(candidates) do
      if vim.fn.hlexists(name) == 1 then
        return name
      end
    end
    return fallback or "Normal"
  end

  local function inherit(group, candidates, extra)
    local target = resolve_group(candidates, "Normal")
    local ok, base = pcall(vim.api.nvim_get_hl, 0, { name = target, link = false })
    if not ok or not base then
      base = {}
    end
    local merged = vim.tbl_extend("force", base, extra or {})
    vim.api.nvim_set_hl(0, group, merged)
  end

  inherit("HomepageHeader1", { "Title", "Statement" })
  inherit("HomepageHeader2", { "Constant", "Type" })
  inherit("HomepageHeader3", { "Statement", "Identifier" })
  inherit("HomepageHeader4", { "Identifier", "Function" })
  inherit("HomepageHeader5", { "Type", "Function" })
  inherit("HomepageInfoIcon", { "Special", "Identifier" })
  inherit("HomepageInfoText", { "Identifier", "Normal" })
  inherit("HomepageInfoSubtle", { "Comment", "NonText" })
  inherit("HomepageInfoAccent", { "Title", "Statement" }, { bold = true })
  inherit("HomepageInfoDivider", { "NonText", "Comment" })
  inherit("HomepageStatIcon", { "Special", "Type" })
  inherit("HomepageStatText", { "Normal" })
  inherit("HomepageGitIcon", { "DiffAdded", "String", "Identifier" })
  inherit("HomepageGitTime", { "Comment", "NonText" })
  inherit("HomepageGitMessage", { "String", "Identifier" })
  inherit(
    "HomepageReadmeHeader",
    { "@markup.heading.1", "@markup.heading", "markdownH1", "markdownHeadingDelimiter", "Title" },
    { bold = true }
  )
  inherit("HomepageMenuKey", { "Keyword", "Statement" }, { bold = true })
  inherit("HomepageMenuIcon", { "Type", "Special" })
  inherit("HomepageMenuText", { "Normal" })
  inherit("HomepageCalToday", { "IncSearch", "Search", "Visual" }, { bold = true })
  inherit("HomepageCalWeek", { "CursorLine", "Visual", "PmenuSel" })

  local header_palette = {
    "HomepageHeader1",
    "HomepageHeader1",
    "HomepageHeader2",
    "HomepageHeader2",
    "HomepageHeader3",
    "HomepageHeader3",
    "HomepageHeader4",
    "HomepageHeader4",
    "HomepageHeader5",
    "HomepageHeader5",
    "HomepageHeader4",
    "HomepageHeader3",
    "HomepageHeader2",
    "HomepageHeader2",
    "HomepageHeader1",
    "HomepageHeader1",
  }

  for i = 1, meta.header_lines do
    if not meta.header_spans then
      local group = header_palette[i] or "HomepageHeader1"
      vim.api.nvim_buf_add_highlight(bufnr, ns, group, i - 1, 0, -1)
    end
  end

  if meta.header_spans then
    for line_idx, spans in ipairs(meta.header_spans) do
      for _, span in ipairs(spans) do
        vim.api.nvim_buf_add_highlight(
          bufnr,
          ns,
          span.group,
          line_idx - 1,
          span.start,
          span.finish
        )
      end
    end
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    if line:find("  ", 1, true) then
      local start = line:find("  ", 1, true)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageInfoIcon", i - 1, start - 1, start + 2)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageInfoText", i - 1, start + 2, -1)
    elseif line:find("󰃭  ", 1, true) then
      local start = line:find("󰃭  ", 1, true)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageInfoIcon", i - 1, start - 1, start + 2)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageInfoText", i - 1, start + 2, -1)
    elseif line:find("  ", 1, true) then
      local start = line:find("  ", 1, true)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageGitIcon", i - 1, start - 1, start + 2)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageInfoText", i - 1, start + 2, -1)
    elseif line:find("  ", 1, true) then
      local start = line:find("  ", 1, true)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageInfoIcon", i - 1, start - 1, start + 2)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageInfoText", i - 1, start + 2, -1)
    elseif line:find("  ", 1, true) then
      local start = line:find("  ", 1, true)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageStatIcon", i - 1, start - 1, start + 2)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageStatText", i - 1, start + 2, -1)
    elseif line:find("  ", 1, true) then
      local start = line:find("  ", 1, true)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageStatIcon", i - 1, start - 1, start + 2)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageStatText", i - 1, start + 2, -1)
    elseif line:find("• ", 1, true) then
      local bullet_start = line:find("• ", 1, true)
      if bullet_start then
        vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageGitIcon", i - 1, bullet_start - 1, bullet_start + 1)
      end
      local sep = line:find(" | ", 1, true)
      if sep then
        local time_start = (bullet_start or 1) + 2
        vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageGitTime", i - 1, time_start - 1, sep - 1)
        vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageInfoSubtle", i - 1, sep - 1, sep + 2)
        vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageGitMessage", i - 1, sep + 2, -1)
      elseif bullet_start then
        vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageGitTime", i - 1, bullet_start + 1, -1)
      end
    elseif line:find("󰂺  README", 1, true) then
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageReadmeHeader", i - 1, 0, -1)
    elseif line:find("Su Mo Tu We Th Fr Sa", 1, true) then
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageInfoSubtle", i - 1, 0, -1)
    elseif line:find("Stay curious. Ship small. Repeat.", 1, true) then
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageInfoAccent", i - 1, 0, -1)
    elseif line:find("──── info ─", 1, true) then
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageInfoDivider", i - 1, 0, -1)
    end
  end

  for line_nr, item in pairs(meta.menu_lines) do
    local line = lines[line_nr]
    local key_start = line:find("%[", 1, true)
    local key_end = line:find("%]", 1, true)
    if key_start and key_end then
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageMenuKey", line_nr - 1, key_start - 1, key_end)
    end
    local icon_pos = line:find(item.icon, 1, true)
    if icon_pos then
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageMenuIcon", line_nr - 1, icon_pos - 1, icon_pos + #item.icon)
      vim.api.nvim_buf_add_highlight(bufnr, ns, "HomepageMenuText", line_nr - 1, icon_pos + #item.icon + 1, -1)
    end
  end

  if meta.calendar_start then
    local today = tonumber(os.date("%d"))
    local calendar = calendar_lines()
    local week_lines = {}
    for i = 3, #calendar do
      table.insert(week_lines, calendar[i])
    end

    local today_token = string.format("%2d", today)
    local current_week = nil
    for _, cal_line in ipairs(week_lines) do
      if cal_line:find(today_token, 1, true) then
        current_week = cal_line
        break
      end
    end

    if current_week then
      local row_index = meta.calendar_start + 1
      for idx, cal_line in ipairs(week_lines) do
        if cal_line == current_week then
          row_index = meta.calendar_start + (idx - 1)
          break
        end
      end

      local row_line = lines[row_index] or ""
      local base = row_line:find(current_week, 1, true)
      if not base then
        return
      end
      for col = 1, #current_week, 3 do
        local token = current_week:sub(col, col + 1)
        if token:match("%d") then
          local day = tonumber(token)
          if day == today then
            vim.api.nvim_buf_add_highlight(
              bufnr,
              ns,
              "HomepageCalToday",
              row_index - 1,
              base + col - 2,
              base + col
            )
          else
            vim.api.nvim_buf_add_highlight(
              bufnr,
              ns,
              "HomepageCalWeek",
              row_index - 1,
              base + col - 2,
              base + col
            )
          end
        end
      end
    end
  end
end

local function open_homepage()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)

  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "homepage"
  vim.bo[bufnr].modifiable = true

  local lines, meta = render_lines(vim.o.columns)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  apply_highlights(bufnr, meta)

  vim.bo[bufnr].modifiable = false
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.cursorline = true

  local menu = menu_entries()
  local menu_line_numbers = {}
  for line_nr, item in pairs(meta.menu_lines) do
    menu_line_numbers[#menu_line_numbers + 1] = { line = line_nr, item = item }
  end
  table.sort(menu_line_numbers, function(a, b)
    return a.line < b.line
  end)

  local function exec(item)
    if type(item.action) == "string" then
      vim.cmd(item.action)
    elseif type(item.action) == "function" then
      item.action()
    end
  end

  for _, item in ipairs(menu) do
    vim.keymap.set("n", item.key, function()
      exec(item)
    end, { buffer = bufnr, silent = true, nowait = true })
  end

  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local entry = meta.menu_lines[line]
    if entry then
      exec(entry)
    end
  end, { buffer = bufnr, silent = true })

  local function move(delta)
    local cursor = vim.api.nvim_win_get_cursor(0)[1]
    local idx = nil
    for i, entry in ipairs(menu_line_numbers) do
      if entry.line == cursor then
        idx = i
        break
      end
    end
    if not idx then
      vim.api.nvim_win_set_cursor(0, { menu_line_numbers[1].line, 0 })
      return
    end
    local next_idx = ((idx - 1 + delta) % #menu_line_numbers) + 1
    vim.api.nvim_win_set_cursor(0, { menu_line_numbers[next_idx].line, 0 })
  end

  vim.keymap.set("n", "j", function()
    move(1)
  end, { buffer = bufnr, silent = true, nowait = true })
  vim.keymap.set("n", "k", function()
    move(-1)
  end, { buffer = bufnr, silent = true, nowait = true })
  vim.keymap.set("n", "<Down>", function()
    move(1)
  end, { buffer = bufnr, silent = true, nowait = true })
  vim.keymap.set("n", "<Up>", function()
    move(-1)
  end, { buffer = bufnr, silent = true, nowait = true })

  if #menu_line_numbers > 0 then
    vim.api.nvim_win_set_cursor(0, { menu_line_numbers[1].line, 0 })
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      if vim.fn.argc() ~= 0 then
        return
      end
      if vim.api.nvim_buf_get_name(0) ~= "" then
        return
      end
      open_homepage()
    end,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      if vim.bo.filetype ~= "homepage" then
        return
      end
      if vim.api.nvim_buf_get_name(0) ~= "" then
        return
      end
      local lines, meta = render_lines(vim.o.columns)
      vim.bo.modifiable = true
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      apply_highlights(0, meta)
      vim.bo.modifiable = false
    end,
  })
end

M.setup()

return M
