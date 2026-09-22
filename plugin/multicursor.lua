-- NOTE: See https://github.com/neovim/neovim/discussions/41997

_G.MultiCursor = {}

MultiCursor.pattern = nil

local ns_mc = vim.api.nvim_create_namespace("nvim.multicursor")
-- local ns_mc_cursor = vim.api.nvim_create_namespace("nvim.multicursor.cursor")
-- local ns_mc_visual = vim.api.nvim_create_namespace("nvim.multicursor.visual")

---@param buf integer
local get_main = function(buf)
  return vim.api.nvim_buf_call(buf, vim.pos.cursor)
end

---@param buf integer
---@param insert_main? boolean
MultiCursor.get_all = function(buf, insert_main)
  local extmarks = vim.api.nvim_buf_get_extmarks(buf, ns_mc, 0, -1)
  local to_pos = function(extm)
    return vim.pos.extmark(buf, extm[2], extm[3])
  end
  local mcursors = vim.tbl_map(to_pos, extmarks)
  local main = get_main(buf)
  if insert_main then
    table.insert(mcursors, main)
    table.sort(mcursors)
    vim.list.unique(mcursors)
  end
  return mcursors, main
end

---@param pos vim.Pos
MultiCursor.set = function(pos)
  vim.api.nvim_mcursor(pos.buf, pos:to_cursor())
end

---@param pos vim.Pos
MultiCursor.del = function(pos)
  local at = { pos:to_extmark() }
  local extmarks = vim.api.nvim_buf_get_extmarks(pos.buf, ns_mc, at, at)
  for _, extm in ipairs(extmarks) do
    local id = extm[1]
    vim.api.nvim_buf_del_extmark(pos.buf, ns_mc, id)
  end
end

---@param buf integer
MultiCursor.clear = function(buf)
  MultiCursor.pattern = nil
  vim.api.nvim_buf_clear_namespace(buf, ns_mc, 0, -1)
end

MultiCursor.actions = {}

---@param dir -1|1
---@param nowrap? boolean
MultiCursor.actions.jump_next = function(dir, nowrap)
  local mcursors = MultiCursor.get_all(0)
  local cursor = vim.pos.cursor()
  local count = vim.v.count1
  if nowrap then
    local before = vim.tbl_filter(function(pos)
      if dir > 0 then
        return pos > cursor
      else
        return pos < cursor
      end
    end, mcursors)
    count = math.min(#before, count)
  end
  -- BUG: Unwrap when resolved: https://github.com/neovim/neovim/issues/41995
  vim.cmd("norm! 2q=")
  vim.schedule(function()
    require("vim._core.mcursor").jump(dir > 0, count)
    vim.cmd("norm! 1q=")
  end)
  if #mcursors ~= #MultiCursor.get_all(0) then
    MultiCursor.del(cursor)
  end
end

---@param dir -1|1
MultiCursor.actions.line_add = function(dir)
  local mcursors = MultiCursor.get_all(0)
  local cursor = vim.pos.cursor()
  local at_edge = vim.tbl_isempty(mcursors)
    or (dir < 0 and cursor <= mcursors[1])
    or (dir > 0 and cursor >= mcursors[#mcursors])
  if at_edge then
    local line_count = vim.api.nvim_buf_line_count(0)
    local row = cursor.row + dir
    while row >= 0 and row < line_count do
      local line = vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
      if cursor.col < math.max(#line, 1) then
        MultiCursor.set(cursor)
        vim.cmd("norm! 2q=")
        vim.api.nvim_win_set_cursor(0, { row + 1, cursor.col })
        vim.cmd("norm! 1q=")
        break
      end
      row = row + dir
    end
  else
    MultiCursor.actions.jump_next(dir, true)
    -- BUG: See `jump_next`
    vim.schedule(function()
      MultiCursor.del(cursor)
      MultiCursor.del(vim.pos.cursor())
    end)
  end
end

---@return string[]?, vim.Range?
local get_visual = function()
  local regtype = string.match(vim.api.nvim_get_mode().mode, "[vV\22]")
  if not regtype then
    return
  end
  local vpos, cpos = vim.fn.getpos("v"), vim.fn.getpos(".")
  local reg = vim.fn.getregion(vpos, cpos, { type = regtype, exclusive = false })
  local regpos = vim.fn.getregionpos(vpos, cpos, { type = regtype, exclusive = false, eol = false, bounds = true })
  local line1, col1 = regpos[1][1][2], regpos[1][1][3]
  local line2, col2 = regpos[#regpos][2][2], regpos[#regpos][2][3]
  local range = vim.range(0, line1 - 1, col1 - 1, line2 - 1, col2)
  return reg, range
end

---@param pattern string
local matchpos_current = function(pattern)
  local pos = function(flags)
    local row, col = unpack(vim.fn.searchpos(pattern, flags))
    return vim.pos(0, row - 1, col - 1)
  end
  local back_end, back_start, forw_end = pos("benW"), pos("bcnW"), pos("cenW")
  local cursor = vim.pos.cursor()
  if back_end >= back_start or cursor < back_start or cursor > forw_end then
    return
  end
  return back_start, forw_end
end

---@param pattern string
local set_search = function(pattern, hlsearch)
  MultiCursor.pattern = pattern
  vim.fn.setreg("/", pattern)
  vim.v.hlsearch = hlsearch or 0
end

---@param force boolean
local expand_search = function(force)
  local reg = vim.fn.getreg("/")
  if not force and vim.v.hlsearch == 1 and reg ~= "" then
    return reg
  end
  local stored = MultiCursor.pattern
  if not force and stored and stored ~= "" then
    return stored
  end
  local vis = get_visual()
  if vis then
    return vis[1]
  end
  local cpos = vim.fn.getpos(".")
  local char = vim.fn.getregion(cpos, cpos)[1]
  if vim.fn.matchstr(char, [[\k]]) ~= "" then
    return [[\<]] .. vim.fn.expand("<cword>") .. [[\>]]
  end
  return [[\V]] .. char
end

---@param force boolean
local search_cursor = function(force, hlsearch)
  local vis = get_visual()
  local pattern = vis and vis[1] or expand_search(force)
  local cursor_match = matchpos_current(pattern)
  if not cursor_match then
    return nil, {}, {}
  end
  if vis then
    vim.cmd("norm! " .. vim.keycode("<Esc>"))
  end
  set_search(pattern, hlsearch)
  vim.cmd("norm! 2q=")
  vim.api.nvim_win_set_cursor(0, cursor_match:to_cursor())
  return pattern, cursor_match, vis
end

MultiCursor.actions.search_current = function()
  search_cursor(true, 1)
end

---@param dir -1|1
---@param add boolean
local match_next = function(dir, add)
  local pattern, cursor_match, vis = search_cursor(true)
  if not pattern then
    return
  end
  if add then
    MultiCursor.set(cursor_match)
  end
  vim.fn.search(pattern, (dir < 0 and "b" or "") .. "W")
  vim.cmd("norm! 1q=")
  if vis then
    vim.cmd("norm! gn")
  end
end

---@param dir -1|1
MultiCursor.actions.match_add = function(dir)
  match_next(dir, true)
end
---@param dir -1|1
MultiCursor.actions.match_skip = function(dir)
  match_next(dir, false)
end

_G.MiniInput = _G.MiniInput

---@param on_confirm fun(input?: string)
---@param on_change? fun(input?: string)
MultiCursor.input = function(opts, on_confirm, on_change)
  on_change = on_change or function() end
  if MiniInput then
    local input = MiniInput.get({
      completion = opts.completion,
      prompt = opts.prompt,
      scope = opts.scope,
      init_keys = { opts.default },
      handlers = {
        key = function(state, key)
          state = MiniInput.default_key(state, key) or state
          on_change(state.input)
          return state
        end,
      },
    })
    on_confirm(input)
    return
  end
  local au_input = vim.api.nvim_create_augroup("multicursor/input", { clear = true })
  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = au_input,
    callback = function()
      if vim.fn.getcmdtype() ~= "@" then
        return true
      end
      local input = vim.fn.getcmdline()
      on_change(input)
      -- HACK: Needed to update `/` search highlight
      vim.api.nvim__redraw({ flush = true })
    end,
  })
  vim.ui.input(opts, function(input)
    vim.api.nvim_clear_autocmds({ group = au_input })
    on_confirm(input)
  end)
end

---@param target? string
---@param range? vim.Range
MultiCursor.actions.search = function(target, range)
  local _, vis_range = get_visual()
  if not range and vis_range then
    range = vis_range
  end
  local filter = ""
  local line_count = vim.api.nvim_buf_line_count(0)
  if range and not (range.start_row == 0 and range.start_col == line_count - 1) then
    -- PERF: Use line range (no column)
    filter = string.gsub([[\%>{R1}l\%<{R2}l]], "{(%w+)}", {
      R1 = range.start_row,
      R2 = range.end_row + 2,
    })
  end
  local to_pattern = function(val)
    return filter .. val
  end
  local view = vim.fn.winsaveview()
  vim.cmd("norm! 2q=")
  local jump_first = function(pattern)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.fn.search(pattern, "c")
  end
  local on_confirm = function(val)
    if not val or val == "" then
      vim.fn.winrestview(view)
      vim.v.hlsearch = 0
    else
      local pattern = to_pattern(val)
      set_search(pattern)
      jump_first(pattern)
      vim.cmd("norm! 1Q1q=")
      MultiCursor.del(vim.pos.cursor())
    end
  end
  local on_change = function(val)
    if val == "" then
      set_search("", 0)
      return
    end
    local pattern = to_pattern(val)
    set_search(pattern, 1)
    jump_first(pattern)
  end
  if target then
    on_confirm(target)
  else
    MultiCursor.input({ prompt = "Match: " }, on_confirm, on_change)
  end
end

-- NOTE: Range search: `<key>ip` prompts for a pattern, placing cursors on matches
MultiCursor.actions.search_operator = function()
  local view = vim.fn.winsaveview()
  local on_operator = function()
    local pos1 = vim.fn.getpos("'[")
    local pos2 = vim.fn.getpos("']")
    local range = vim.range(0, pos1[2] - 1, pos1[3] - 1, pos2[2] - 1, pos2[3])
    vim.fn.winrestview(view)
    vim.schedule(function()
      MultiCursor.actions.search(nil, range)
    end)
  end
  vim.go.operatorfunc = on_operator
  return "g@"
end

-- NOTE: Counted motions: `3<key>j` = `QjQjQj`, `2<key>w` = `QwQw`
--
-- ```lua
-- vim.keymap.set("n", "Q", function()
--   return vim.v.count > 0 and MultiCursor.actions.motion_operator() or "Q"
-- end, { expr = true })
-- ```
MultiCursor.actions.motion_operator = function()
  local on_atom = function(e)
    local d = e.data
    if d.type == "operator" then
      for _ = 1, d.count or 1 do
        vim.api.nvim_mcursor(0, vim.pos.cursor():to_cursor())
        vim.cmd("norm " .. d.cmd)
      end
      vim.cmd("norm! 1q=")
    end
  end
  vim.api.nvim_create_autocmd("CmdAtom", { once = true, callback = on_atom })
  vim.go.operatorfunc = function() end
  return "g@"
end

MultiCursor.actions.align = function()
  local mcursors, cursor = MultiCursor.get_all(0, true)
  ---@type vim.Pos
  local rightmost = vim.iter(mcursors):fold(cursor, function(max, mc)
    return mc.col >= max.col and mc or max
  end)
  for _, mc in ipairs(mcursors) do
    local delta = rightmost.col - mc.col
    if delta > 0 then
      local pad = string.rep(" ", delta)
      vim.api.nvim_buf_set_text(0, mc.row, mc.col, mc.row, mc.col, { pad })
    end
  end
end

MultiCursor.actions.split_visual = function()
  -- How?
end

-- vim.keymap.set("n", "<Esc>", function()
--   MultiCursor.clear(0)
--   vim.cmd("nohls")
--   return "<Esc>"
-- end, { expr = true, desc = "Clear on <Esc>" })

-- stylua: ignore start
-- vim.keymap.set({ "n", "x" }, "<C-8>", function() MultiCursor.actions.search_current() end, { desc = "Expand search" }) -- <C-*>
vim.keymap.set("n", "<S-Right>", function() MultiCursor.actions.jump_next(1) end, { desc = "Cursors: next" })
vim.keymap.set("n", "<S-Left>", function() MultiCursor.actions.jump_next(-1) end, { desc = "Cursors: previous" })
vim.keymap.set("n", "<S-Down>", function() MultiCursor.actions.line_add(1) end, { desc = "Cursors: add below" })
vim.keymap.set("n", "<S-Up>", function() MultiCursor.actions.line_add(-1) end, { desc = "Cursors: add above" })
vim.keymap.set("n", "<C-S-j>", function() MultiCursor.actions.line_add(1) end, { desc = "Cursors: add below" })
vim.keymap.set("n", "<C-S-k>", function() MultiCursor.actions.line_add(-1) end, { desc = "Cursors: add above" })
vim.keymap.set({ "n", "x" }, "<C-n>", function() MultiCursor.actions.match_add(1) end, { desc = "Cursors: add match next" })
vim.keymap.set({ "n", "x" }, "<C-p>", function() MultiCursor.actions.match_add(-1) end, { desc = "Cursors: add match previous" })
vim.keymap.set({ "n", "x" }, "<C-S-n>", function() MultiCursor.actions.match_skip(1) end, { desc = "Cursors: skip match next" })
vim.keymap.set({ "n", "x" }, "<C-S-p>", function() MultiCursor.actions.match_skip(-1) end, { desc = "Cursors: skip match previous" })
vim.keymap.set("x", "gm", function() MultiCursor.actions.search() end, { desc = "Cursors: search" })
vim.keymap.set("n", "gm", MultiCursor.actions.search_operator, { expr = true, desc = "Cursors: search operator" })
vim.keymap.set("n", "<Leader><leader>A", function() MultiCursor.actions.align() end, { desc = "Cursors: align" })
