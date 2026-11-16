-- NOTE: See https://github.com/neovim/neovim/discussions/41997
_G.MultiCursor = {}

MultiCursor.pattern = nil

local ns_anchor = vim.api.nvim_create_namespace("nvim.multicursor")
local ns_cursor = vim.api.nvim_create_namespace("nvim.multicursor.cursor")
local ns_visual = vim.api.nvim_create_namespace("nvim.multicursor.visual")

MultiCursor.is_cascading = function()
  return vim.v.cascading
end

---@param buf integer
MultiCursor.is_active = function(buf)
  return #vim.api.nvim_buf_get_extmarks(buf, ns_anchor, 0, -1, { limit = 1 }) > 0
end

---@param buf integer
MultiCursor.is_follow = function(buf)
  return vim.bo[buf].follow
end

---@param buf integer
---@param enable? boolean
MultiCursor.toggle_follow = function(buf, enable)
  enable = vim.nonnil(enable, not MultiCursor.is_follow(buf))
  ---@cast enable boolean
  vim.bo[buf].follow = enable
end

local pack_len = function(...)
  return { n = select("#", ...), ... }
end

-- NOTE: `vim._with` doesn't support yielding in an async context
---@param buf integer
---@param fn function
---@return any ...
MultiCursor.call_nofollow = function(buf, fn)
  local is_follow = MultiCursor.is_follow(buf)
  MultiCursor.toggle_follow(buf, false)
  local res = pack_len(fn())
  MultiCursor.toggle_follow(buf, is_follow)
  return unpack(res, 1, res.n)
end

local get_visual = function()
  ---@type string?
  local regtype = string.match(vim.api.nvim_get_mode().mode, "[vV\22]")
  if not regtype then
    return
  end
  local vpos, cpos = vim.fn.getpos("v"), vim.fn.getpos(".")
  local reg = vim.fn.getregion(vpos, cpos, {
    type = regtype,
    exclusive = false,
  })
  local regpos = vim.fn.getregionpos(vpos, cpos, {
    type = regtype,
    exclusive = false,
    eol = false,
    bounds = true,
  })
  local r1, r2 = regpos[1][1], regpos[#regpos][2]
  local rg = vim.range.extmark(0, r1[2] - 1, r1[3] - 1, r2[2] - 1, r2[3])
  return reg, rg
end

---@class MultiCursor.Primary : vim.Range
---@field start vim.Pos
---@field visual vim.Pos
---@field cursor vim.Pos
---@field is_primary boolean

---@class MultiCursor.Secondary : MultiCursor.Primary
---@field anchor_id integer
---@field visual_id? integer
---@field cursor_id? integer

---@alias MultiCursor.Entry MultiCursor.Primary|MultiCursor.Secondary

---@param buf integer
---@return MultiCursor.Primary
MultiCursor.primary = function(buf)
  return vim.api.nvim_buf_call(buf, function()
    local cursor = vim.pos.cursor()
    local range = vim.range(cursor, cursor) -- Collapsed
    local visual = cursor
    local _, vis_range = get_visual()
    if vis_range then
      range = vis_range
      local vp = vim.fn.getpos("v")
      visual = vim.pos.mark(0, vp[2], vp[3] - 1)
    end
    local start = cursor < visual and cursor or visual
    local primary = range --[[@as MultiCursor.Primary]]
    primary.start = start
    primary.cursor = cursor
    primary.visual = visual
    primary.is_primary = true
    return primary
  end)
end

---@param buf integer
---@return MultiCursor.Secondary[], MultiCursor.Primary
MultiCursor.get = function(buf)
  local extms_anchor = vim.api.nvim_buf_get_extmarks(buf, ns_anchor, 0, -1)
  local extms_cursor = vim.api.nvim_buf_get_extmarks(buf, ns_cursor, 0, -1)
  local extms_visual = vim.api.nvim_buf_get_extmarks(buf, ns_visual, 0, -1, { details = true })
  local mcursors = {} ---@type MultiCursor.Secondary[]
  for i = 1, #extms_anchor do
    local a, c, v = extms_anchor[i], extms_cursor[i], extms_visual[i]
    local anchor = vim.pos.extmark(buf, a[2], a[3])
    local range = vim.range(anchor, anchor)
    local cursor, visual = anchor, anchor
    if v and c then -- Visual
      local visual_start = vim.pos.extmark(buf, v[2], v[3])
      local visual_end_excl = vim.pos.extmark(buf, v[4].end_row, v[4].end_col)
      local visual_end_incl = vim.pos.extmark(buf, v[4].end_row, v[4].end_col - 1)
      range = vim.range(visual_start, visual_end_excl)
      cursor = vim.pos.extmark(buf, c[2], c[3])
      visual = cursor == visual_start and visual_end_incl or visual_start
    end
    local start = cursor < visual and cursor or visual
    local mc = range --[[@as MultiCursor.Secondary]]
    mc.start = start
    mc.cursor = cursor
    mc.visual = visual
    mc.is_primary = false
    -- Extend
    mc.anchor_id = a[1]
    mc.cursor_id = c and c[1]
    mc.visual_id = v and v[1]
    table.insert(mcursors, mc)
  end
  local primary = MultiCursor.primary(buf)
  return mcursors, primary
end

MultiCursor.util = {}

---@param ranges vim.Range[]
MultiCursor.util.sort = function(ranges)
  table.sort(ranges)
end

---@param ranges vim.Range[]
MultiCursor.util.unique = function(ranges)
  vim.list.unique(ranges, function(rg)
    return table.concat({ rg:to_extmark() }, ":")
  end)
end

---@param buf integer
---@param unique? boolean
---@return MultiCursor.Entry[], MultiCursor.Primary
MultiCursor.get_all = function(buf, unique)
  local mcursors, primary = MultiCursor.get(buf)
  table.insert(mcursors, primary)
  if unique ~= false then
    MultiCursor.util.unique(mcursors)
  end
  MultiCursor.util.sort(mcursors)
  return mcursors, primary
end

---@param pos_rg vim.Pos|vim.Range
local as_rg = function(pos_rg)
  if pos_rg.row and pos_rg.col then
    ---@cast pos_rg vim.Pos
    return vim.range(pos_rg, pos_rg)
  end
  ---@cast pos_rg vim.Range
  return pos_rg
end

---@param pos_rg vim.Pos
MultiCursor.set = function(pos_rg)
  local rg = as_rg(pos_rg)
  vim.api.nvim_buf_set_extmark(rg.buf, ns_anchor, rg.start_row, rg.start_col, {})
end

---@param pos_rg vim.Pos|vim.Range
MultiCursor.del_at = function(pos_rg)
  local rg = as_rg(pos_rg)
  local mcursors = MultiCursor.get(rg.buf)
  for _, mc in ipairs(mcursors) do
    if rg == mc or rg:has(mc) then
      vim.api.nvim_buf_del_extmark(rg.buf, ns_anchor, mc.anchor_id)
      if mc.cursor_id then
        vim.api.nvim_buf_del_extmark(rg.buf, ns_visual, mc.cursor_id)
      end
      if mc.visual_id then
        vim.api.nvim_buf_del_extmark(rg.buf, ns_visual, mc.visual_id)
      end
    end
  end
end

---@param buf integer
MultiCursor.clear = function(buf)
  MultiCursor.pattern = nil
  vim.api.nvim_buf_clear_namespace(buf, ns_anchor, 0, -1)
  vim.api.nvim_buf_clear_namespace(buf, ns_cursor, 0, -1)
  vim.api.nvim_buf_clear_namespace(buf, ns_visual, 0, -1)
end

---@param pos? vim.Pos
---@param count? integer +/-
---@param nowrap? boolean
MultiCursor.jump = function(pos, count, nowrap)
  pos = pos or vim.pos.cursor()
  count = count or vim.v.count1
  local buf = pos.buf
  local forward, jump_count = count > 0, math.abs(count)
  if nowrap then
    local max_count = 0
    local mcursors = MultiCursor.get(buf)
    for _, mc in ipairs(mcursors) do
      local start = vim.pos(mc.buf, mc.start_row, mc.start_col)
      if (forward and start > pos) or (not forward and start < pos) then
        max_count = max_count + 1
      end
    end
    jump_count = math.min(jump_count, max_count)
  end
  if jump_count == 0 then
    return
  end
  MultiCursor.call_nofollow(buf, function()
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("norm! " .. jump_count .. (forward and "]C" or "[C"))
    end)
  end)
end

MultiCursor.actions = {}

---@param dir -1|1
---@param count? integer
---@param nowrap? boolean
MultiCursor.actions.jump_next = function(dir, count, nowrap)
  count = count or vim.v.count1
  local is_follow = MultiCursor.is_follow(0)
  local cursor = vim.pos.cursor()
  if is_follow then
    MultiCursor.set(cursor)
  end
  MultiCursor.jump(cursor, dir * count, nowrap)
  if is_follow then
    MultiCursor.del_at(vim.pos.cursor())
  end
end

---@param pos vim.Pos
---@param dir -1|1
---@param count integer
local line_add = function(pos, dir, count)
  local col = pos.col
  local row = pos.row + dir
  local line_count = vim.api.nvim_buf_line_count(0)
  while count > 0 and row >= 0 and row < line_count do
    local col_count = #vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
    if col < math.max(col_count, 1) then
      MultiCursor.set(vim.pos.cursor())
      MultiCursor.call_nofollow(0, function()
        vim.api.nvim_win_set_cursor(0, { row + 1, col })
      end)
      count = count - 1
    end
    row = row + dir
  end
end

---@param dir -1|1
---@param count? integer
MultiCursor.actions.line_add = function(dir, count)
  count = count or vim.v.count1
  local mcursors, primary = MultiCursor.get(0)
  local at_edge = not MultiCursor.is_active(0)
    or (dir < 0 and primary <= mcursors[1])
    or (dir > 0 and primary >= mcursors[#mcursors])
  if not MultiCursor.is_active(0) then
    MultiCursor.toggle_follow(0, true)
  end
  ---@type vim.Pos
  local pos = vim.pos(0, primary.start_row, primary.start_col)
  if at_edge or not MultiCursor.is_follow(0) then
    line_add(pos, dir, count)
  else
    MultiCursor.actions.jump_next(dir, count, true)
    MultiCursor.del_at(pos)
  end
end

---@param pattern string
---@return vim.Range?
local match_current = function(pattern)
  local pos = function(flags)
    local row, col = unpack(vim.fn.searchpos(pattern, flags))
    return vim.pos.mark(0, row, col - 1)
  end
  local back_end, back_start, forw_end = pos("benW"), pos("bcnW"), pos("cenW")
  local cursor = vim.pos.cursor()
  if back_end >= back_start or cursor < back_start or cursor > forw_end then
    return
  end
  forw_end.col = forw_end.col + 1
  return vim.range(back_start, forw_end)
end

local def_hlsearch = 0
---@param pattern string
local set_search = function(pattern, hlsearch, histadd)
  MultiCursor.pattern = pattern
  vim.fn.setreg("/", pattern)
  vim.v.hlsearch = hlsearch or def_hlsearch
  if histadd then
    vim.fn.histadd("search", pattern)
  end
end

local esc_search = function(str)
  return vim.fn.escape(str, [[\]])
end

---@param force boolean
---@return string
local expand_search = function(force)
  if not force then
    local reg = vim.fn.getreg("/")
    if vim.v.hlsearch == 1 and reg ~= "" then
      return reg
    end
    local stored = MultiCursor.pattern
    if stored and stored ~= "" then
      return stored
    end
  end
  local vis = get_visual()
  if vis then
    return [[\C\V]] .. esc_search(vis[1])
  end
  local cpos = vim.fn.getpos(".")
  local char = vim.fn.getregion(cpos, cpos)[1]
  if vim.fn.matchstr(char, [[\k]]) ~= "" then
    return [[\C\V\<]] .. esc_search(vim.fn.expand("<cword>")) .. [[\>]]
  end
  return [[\C\V]] .. esc_search(char)
end

local stop_visual = function()
  local vis, vis_rg = get_visual()
  if vis then
    vim.cmd("norm! " .. vim.keycode("<Esc>"))
  end
  return vis, vis_rg
end

MultiCursor.actions.search_current = function()
  local pattern = expand_search(true)
  local match_rg = match_current(pattern)
  if not match_rg then
    return
  end
  local match_pos = vim.pos(0, match_rg.start_row, match_rg.start_col)
  stop_visual()
  if not MultiCursor.is_cascading() then
    set_search(pattern, 1)
  end
  vim.api.nvim_win_set_cursor(0, match_pos:to_cursor())
end

---@param dir -1|1
---@param add boolean
---@param count integer
local match_next = function(dir, add, count)
  if MultiCursor.is_cascading() then
    return
  end
  count = count or vim.v.count1
  local pattern = expand_search(false)
  local match_rg = match_current(pattern)
  if not match_rg then
    return
  end
  local match_pos = vim.pos(0, match_rg.start_row, match_rg.start_col)
  stop_visual()
  set_search(pattern)
  vim.api.nvim_win_set_cursor(0, match_pos:to_cursor())
  if add then
    MultiCursor.set(match_pos)
  end
  local flags = "W" .. (dir > 0 and "" or "b")
  for _ = 1, count do
    local lnum = vim.fn.search(pattern, flags)
    if lnum < 1 then
      break
    end
    if add then
      MultiCursor.set(vim.pos.cursor())
    end
  end
  MultiCursor.del_at(vim.pos.cursor())
  MultiCursor.toggle_follow(0, true)
  -- NOTE: Type manually: `feedkeys()` causes visible flicker
  -- if vis then
  --   vim.api.nvim_feedkeys("gn", "n", true)
  -- end
end

---@param dir -1|1
MultiCursor.actions.match_add = function(dir)
  match_next(dir, true, vim.v.count1)
end
---@param dir -1|1
MultiCursor.actions.match_skip = function(dir)
  match_next(dir, false, vim.v.count1)
end

-- BUG: Doesn't handle exclusive motions well. See https://github.com/neovim/neovim/issues/42228
---@param mode? "char"|"line"|"block"
local get_operator = function(mode)
  local pos1, pos2 = vim.fn.getpos("'["), vim.fn.getpos("']")
  local motion_map = { char = "v", line = "V", block = "\22" }
  local regtype = motion_map[mode] or "v"
  local reg = vim.fn.getregion(pos1, pos2, {
    type = regtype,
    exclusive = false,
  })
  local regpos = vim.fn.getregionpos(pos1, pos2, {
    type = regtype,
    exclusive = false,
    eol = false,
    bounds = true,
  })
  local p1, p2 = regpos[1][1], regpos[1][2]
  local rg = vim.range.extmark(0, p1[2] - 1, p1[3] - 1, p2[2] - 1, p2[3])
  local pos = vim.pos.cursor()
  return reg, rg, pos
end

local async = vim.async

local async_run = function(cb)
  -- NOTE: Should be non-blocking, don't use `:wait()`
  async.run(cb):raise_on_error()
end

---@param fn function
local await_set_repeat = function(fn)
  async.await(function(done)
    vim.o.operatorfunc = function()
      vim.o.operatorfunc = function()
        if MultiCursor.is_cascading() then
          return
        end
        fn()
      end
      done()
    end
    vim.api.nvim_feedkeys("g@l", "n", true)
  end)
end

---@param atom vim.event.cmdatom.data
local is_textobject = function(atom)
  return atom.type == "operator" and (string.match(atom.cmd, "^[ia].") or string.match(atom.lhs, "%d*[ia].$"))
end

-- NOTE: Match <what> in <where> <n> times
--
-- Only the first operator moves the cursor, but otherwise order doesn't matter:
-- the smaller range defines <what> to match, while the larger defines <where> to match.
-- With a count, a textobject selects the first <n> matches,
-- while a motion selects the next <n> matches in the given direction.
--
-- The function sets dot-repeat even if canceled midway.
--
-- ```lua
-- vim.keymap.set("n", "gm", function() MultiCursor.multi_operator() end, { desc = "Match operator" })
-- ```
--
-- Examples:
--   gm<iw><10j> - match <inner word> in the next <10 lines>
--   2gm<iw><gg> - match the next <2> <inner word> matches up to the <first line>
--   2gm<iw><al> - match the first <2> <inner word> matches in <around lines> (whole buffer)
--   ...
--
---@async
---@param opts? { op1?: string, op2?: string, count?: integer }
---@param _atom1? vim.event.cmdatom.data
---@param _atom2? vim.event.cmdatom.data
MultiCursor.multi_operator = function(opts, _atom1, _atom2)
  if MultiCursor.is_cascading() then
    return
  end
  opts = vim.tbl_extend("keep", opts or {}, { count = vim.v.count })
  local op1, op2, count = opts.op1, opts.op2, opts.count
  local init_view = vim.fn.winsaveview()
  local is_active = MultiCursor.is_active(0)
  local is_follow = MultiCursor.is_follow(0)
  local on_cancel = function()
    vim.fn.winrestview(init_view)
  end
  local read_operator = function(view)
    local _, rg, pos = get_operator("char")
    local init_pos = vim.pos.cursor(0, { view.lnum, view.col })
    local dir = pos < init_pos and -1 or 1
    return rg, dir
  end
  local feed_operator = function(atom, op)
    if atom then
      vim.api.nvim_feedkeys(atom.keys, "n", false)
      return
    end
    local is_visual = get_visual()
    vim.api.nvim_feedkeys("g@", "n", false)
    if op and not is_visual then
      vim.api.nvim_feedkeys(op, "m", false)
    end
  end
  async_run(function()
    local rg1, dir1, rg2, dir2
    ---@param done function
    ---@type string?, integer, vim.event.cmdatom.data
    local err, called, atom = async.await(function(done) ---@diagnostic disable-line: assign-type-mismatch
      local called = 0
      local id = vim.api.nvim_create_autocmd("CmdAtom", {
        once = true,
        callback = function(e)
          done(nil, called, e.data)
        end,
      })
      local opfunc = function(fn)
        return function(mode)
          if MultiCursor.is_cascading() then
            return
          end
          local ok, err = xpcall(fn, debug.traceback, mode)
          if not ok then
            pcall(vim.api.nvim_del_autocmd, id)
            done(err, called, nil)
          end
        end
      end
      local view1 = init_view
      vim.o.operatorfunc = opfunc(function()
        called, rg1, dir1 = 1, read_operator(view1)
        local view2 = vim.fn.winsaveview()
        vim.o.operatorfunc = opfunc(function()
          called, rg2, dir2 = 2, read_operator(view2)
          -- NOTE: Keep the second operator from moving the cursor
          vim.fn.winrestview(view2)
        end)
        feed_operator(_atom2, op2)
      end)
      feed_operator(_atom1, op1)
    end)
    if err then
      error(err, 0)
    end
    if not atom.atoms or called == 0 then
      await_set_repeat(function()
        MultiCursor.multi_operator(opts)
      end)
      -- on_cancel()
      return
    end
    local atom1 = atom.atoms[1]
    if called == 1 then
      await_set_repeat(function()
        MultiCursor.multi_operator(opts, atom1)
      end)
      on_cancel()
      return
    end
    local atom2 = atom.atoms[2]
    await_set_repeat(function()
      MultiCursor.multi_operator(opts, atom1, atom2)
    end)
    ---@param r1 vim.Range
    ---@param r2 vim.Range
    local lt = function(r1, r2)
      local d1 = math.abs(r1.end_row - r1.start_row)
      local d2 = math.abs(r2.end_row - r2.start_row)
      if d1 == d2 then
        d1 = math.abs(r1.end_col - r1.start_col)
        d2 = math.abs(r2.end_col - r2.start_col)
      end
      return d1 < d2
    end
    local sm = { rg = rg1, dir = dir1 }
    local lg = { rg = rg2, dir = dir2 }
    if lt(rg2, rg1) then
      sm, lg = lg, sm
    end
    local dir = is_textobject(lg) and 0 or lg.dir
    local rg_text = function(rg)
      local sr, sc, er, ec = rg:to_extmark()
      local text = vim.api.nvim_buf_get_text(0, sr, sc, er, ec, {})
      return table.concat(text, "\n")
    end
    local pattern = [[\V\C]] .. esc_search(rg_text(sm.rg))
    local range = lg.rg
    ---@type { lnum: integer, byteidx: integer, text: string }[]
    local line_matches = vim.fn.matchbufline("%", pattern, range.start_row + 1, range.end_row + 1)
    local cursor = vim.pos.cursor()
    local matches, cursor_i = {}, nil
    for _, lnm in ipairs(line_matches) do
      local start = vim.pos.mark(0, lnm.lnum, lnm.byteidx)
      local rg = vim.range(start, vim.pos.mark(0, lnm.lnum, lnm.byteidx + #lnm.text))
      if range:intersect(rg) then
        table.insert(matches, start)
        if start <= cursor then
          cursor_i = #matches
        end
      end
    end
    if not cursor_i then
      return on_cancel()
    end
    local from, to, step = 1, #matches, 1
    if count > 0 then
      if dir == 0 then
        to = math.min(count, #matches)
        cursor_i = to
      else
        from, step = cursor_i, dir
        to = math.max(1, math.min(cursor_i + dir * count, #matches))
      end
    end
    for i = from, to, step do
      if i ~= cursor_i then
        MultiCursor.set(matches[i])
      end
    end
    if is_active and is_follow then
      MultiCursor.set(cursor)
    end
    local jump = matches[cursor_i]
    vim.api.nvim_win_set_cursor(0, jump:to_cursor())
    MultiCursor.toggle_follow(0, true)
  end)
end

-- NOTE: Match cword in <where> (subcase of `multi_operator`)
--
-- Examples:
--   <key><al> - match cword in <around lines> (whole buffer)
--
MultiCursor.actions.cword_operator = function()
  MultiCursor.multi_operator({ op1 = "iw" })
end

_G.MiniInput = _G.MiniInput

---@param on_confirm fun(input?: string)
---@param on_change? fun(input: string)
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
          if state.status == "progress" then
            on_change(state.input)
          end
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
        return
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

---@param range? vim.Range
MultiCursor.actions.search = function(range)
  if MultiCursor.is_cascading() then
    return
  end
  local _, vis_rg = stop_visual()
  range = range or vis_rg
  local line_count = vim.api.nvim_buf_line_count(0)
  local search_prefix = ""
  if range and not (range.start_row == 0 and range.end_row == line_count - 1) then
    -- PERF: Use line range (no column)
    search_prefix = string.gsub([[\%>{R1}l\%<{R2}l]], "{(%w+)}", {
      R1 = range.start_row,
      R2 = range.end_row + 2,
    })
  end
  local search_first = function(input)
    if not input or input == "" then
      return
    end
    local pattern = search_prefix .. input
    -- Has match
    local ok, res = pcall(vim.fn.search, pattern, "nw")
    if not ok or res == 0 then
      return
    end
    -- Jump first
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.fn.searchpos(pattern, "cW")
    return pattern
  end
  local reg = vim.fn.getreg("/")
  local view = vim.fn.winsaveview()
  local is_active = MultiCursor.is_active(0)
  local is_follow = MultiCursor.is_follow(0)
  local on_change = function(input)
    local pattern = search_first(input)
    if not pattern then
      set_search("", 0)
      return
    end
    set_search(pattern, 1)
  end
  local on_confirm = function(input)
    local pattern = search_first(input)
    if not pattern then
      set_search(reg, 0)
      vim.fn.winrestview(view)
      MultiCursor.toggle_follow(0, is_follow)
      return
    end
    if is_active and is_follow then
      MultiCursor.set(vim.pos.mark(0, view.lnum, view.col))
    end
    set_search(pattern, 0)
    local first = vim.pos.cursor()
    while vim.fn.search(pattern, "W") > 0 do
      MultiCursor.set(vim.pos.cursor())
    end
    vim.api.nvim_win_set_cursor(0, first:to_cursor())
    MultiCursor.toggle_follow(0, true)
  end
  MultiCursor.toggle_follow(0, false)
  -- BUG: Prevent self-triggered cascading
  on_confirm = vim.schedule_wrap(on_confirm)
  MultiCursor.input({ prompt = "Search: " }, on_confirm, on_change)
end

-- NOTE: Search and place in <where>
--
-- Examples:
--   <key>al - prompt for a pattern; place matches in <around lines> (whole buffer)
--
MultiCursor.actions.search_operator = function()
  local view = vim.fn.winsaveview()
  vim.o.operatorfunc = function(motion)
    if MultiCursor.is_cascading() then
      return
    end
    vim.fn.winrestview(view)
    local _, rg = get_operator(motion)
    MultiCursor.actions.search(rg)
  end
  vim.api.nvim_feedkeys("g@", "n", true)
end

---@async
---@param fn? string|fun(mode: string)
---@return vim.event.cmdatom.data?
local await_motion = function(fn, keys, feed_mode, escape_ks)
  if fn == nil or fn == "" then
    fn = function() end
  elseif type(fn) == "string" then
    local ref = fn
    fn = function(mode)
      vim.fn.call(ref, { mode })
    end
  end
  keys = keys or "g@"
  feed_mode = feed_mode or "n"
  escape_ks = vim.nonnil(escape_ks, true) --[[@as boolean]]
  ---@cast fn function
  ---
  ---@param done function
  ---@type boolean, string?, vim.event.cmdatom.data
  local called, err, atom = async.await(function(done) ---@diagnostic disable-line
    local called, err = false, nil
    vim.o.operatorfunc = function(mode)
      if err then
        -- NOTE: No cascade on error
        return
      end
      called = true
      local ok, res = xpcall(fn, debug.traceback, mode)
      if not ok then
        err = res
      end
    end
    -- 2
    vim.api.nvim_create_autocmd("CmdAtom", {
      once = true,
      callback = function(e)
        done(called, err, e.data)
      end,
    })
    vim.api.nvim_feedkeys(keys, feed_mode, escape_ks)
  end)
  if not called then
    return -- Cancel
  end
  if err then
    error(err, 0) -- Raise
  end
  return atom
end

-- [Not mapped]
-- NOTE: Repeat Q<motion> <n> times
--
-- When <motion> is a textobject, place cursors at each selection's start;
-- otherwise, at the position of each repeated motion.
--
-- ```lua
-- vim.keymap.set("n", "Q", function()
--   return vim.v.count > 0 and MultiCursor.actions.motion_operator() or "Q"
-- end, { expr = true })
-- ```
--
-- Examples:
--   2<key>3iw - place <2> cursors at the start of every 3rd <inner word> (3rd and 6th)
--   3<key>j   - the same as `QjQjQj`
--   3<key>2w  - the same as `Q2wQ2wQ2w`
--
---@param count? integer
---@param _atom vim.event.cmdatom.data?
MultiCursor.actions.motion_operator = function(count, _atom)
  count = count or vim.v.count1
  local view = vim.fn.winsaveview()
  async_run(function()
    local atom = _atom
      or await_motion(function()
        if not MultiCursor.is_cascading() then
          vim.fn.winrestview(view)
        end
      end)
    if not atom then
      return
    end
    -- Counts: <n1>Q<n2>w
    local n1, n2 = count, (atom.count or count) / count
    local keys = assert(atom.keys):gsub("^%d+", n2)
    if is_textobject(atom) then
      local textobj_keys = keys:gsub("^%d+", "")
      local rgs = {}
      local ww = vim.o.whichwrap
      vim.o.whichwrap = ww .. "l"
      for _ = 1, n1 * n2 do
        vim.o.operatorfunc = function(mode)
          if MultiCursor.is_cascading() then
            return
          end
          local _, rg = get_operator(mode)
          table.insert(rgs, rg)
        end
        vim.api.nvim_feedkeys(textobj_keys .. "`]l", "nx", false)
      end
      vim.o.whichwrap = ww
      vim.fn.winrestview(view)
      for i, rg in ipairs(rgs) do
        if i % n2 == 0 then
          MultiCursor.set(vim.pos(0, rg.start_row, rg.start_col))
        end
      end
      MultiCursor.toggle_follow(0, false)
    else
      local motion_keys = keys:gsub("g@", "", 1)
      for _ = 1, n1 do
        vim.api.nvim_feedkeys(motion_keys, "nx", false)
        MultiCursor.set(vim.pos.cursor())
      end
      vim.fn.winrestview(view)
      MultiCursor.toggle_follow(0, true)
    end
    await_set_repeat(function()
      MultiCursor.actions.motion_operator(count, atom)
    end)
  end)
end

-- [Not mapped]
-- NOTE: Rotate <motion> selections across cursors <n> times
--
-- ```lua
-- vim.keymap.set({ "n", "x" }, "<Leader>t", function() MultiCursor.actions.rotate_operator(1) end)
-- vim.keymap.set({ "n", "x" }, "<Leader>T", function() MultiCursor.actions.rotate_operator(-1) end)
-- ```
--
-- Examples:
--   2<key>iw  - rotate <inner word> selections <2> times
--   viw2<key> - the same as `2<key>iw`
--
---@param dir -1|1
---@param count? integer
---@param _atom? vim.event.cmdatom.data
MultiCursor.actions.rotate_operator = function(dir, count, _atom)
  if MultiCursor.is_cascading() then
    return
  end
  count = count or vim.v.count1
  local shift_count = dir * count
  local init_visual = get_visual() ~= nil
  local init_view = vim.fn.winsaveview()
  local mcursors = MultiCursor.get_all(0, false)
  local cascade_to_rgs = function(cursors, atom)
    local view = vim.fn.winsaveview()
    local results = {}
    for _, mc in ipairs(cursors) do
      vim.api.nvim_win_set_cursor(0, mc.cursor:to_cursor())
      vim.o.operatorfunc = function(mode)
        if MultiCursor.is_cascading() then
          return
        end
        local _, rg = get_operator(mode)
        table.insert(results, rg)
      end
      vim.api.nvim_feedkeys(atom.keys, "nx", false)
    end
    vim.fn.winrestview(view)
    return results
  end
  async_run(function()
    local atom = _atom
      or await_motion(function()
        if not MultiCursor.is_cascading() then
          vim.fn.winrestview(init_view)
        end
      end)
    if not atom then
      return
    end
    ---@type vim.Range[]
    local selections = mcursors
    if not init_visual then
      -- NOTE: Replay the atom for each cursor
      selections = cascade_to_rgs(mcursors, atom)
    end
    -- Create placements (merge ranges)
    ---@class MultiCursor.rotate.Placement
    ---@field sel vim.Range
    ---@field mcs MultiCursor.Entry[]
    ---@field text string[]
    ---
    ---@type MultiCursor.rotate.Placement[]
    local _placements = {}
    for i, sel in ipairs(selections) do
      table.insert(_placements, { sel = sel, mcs = { mcursors[i] } })
    end
    -- table.sort(_placements, function(a, b)
    --   a, b = a.sel, b.sel
    --   return a.start_row < b.start_row or (a.start_row == b.start_row and a.start_col < b.start_col)
    -- end)
    ---@type MultiCursor.rotate.Placement[]
    local placements = {}
    -- NOTE: Expects placements sorted by start
    for _, pl in ipairs(_placements) do
      local last = placements[#placements]
      if last and last.sel:intersect(pl.sel) then
        -- Mutate last
        vim.list_extend(last.mcs, pl.mcs)
        if not last.sel:has(pl.sel) then
          last.sel = vim.range(0, last.sel.start_row, last.sel.start_col, pl.sel.end_row, pl.sel.end_col)
        end
      else
        table.insert(placements, pl)
      end
    end
    for _, pl in ipairs(placements) do
      local sr, sc, er, ec = pl.sel:to_extmark()
      pl.text = vim.api.nvim_buf_get_text(0, sr, sc, er, ec, {})
    end
    -- Apply edits
    local dst = function(i)
      local j = ((i - shift_count - 1) % #placements) + 1
      return placements[j]
    end
    for i = #placements, 1, -1 do
      local pl, npl = placements[i], dst(i)
      local sr, sc, er, ec = pl.sel:to_extmark()
      -- NOTE: Shifts extmarks
      vim.api.nvim_buf_set_text(0, sr, sc, er, ec, npl.text)
    end
    -- Set cursors
    MultiCursor.clear(0)
    for i, pl in ipairs(placements) do
      local npl = dst(i)
      local off2 = vim.pos(0, npl.sel.start_row, npl.sel.start_col):to_offset()
      local off1 = vim.pos(0, pl.sel.start_row, pl.sel.start_col):to_offset()
      local off_diff = off2 - off1
      for _, mc in ipairs(npl.mcs) do
        local pos = init_visual and mc.visual or mc.cursor
        local off = off_diff
        if npl.sel:has(pos) then
          off = pos:to_offset() - off_diff
        end
        pos = vim.pos.offset(0, off)
        if mc.is_primary then
          vim.api.nvim_win_set_cursor(0, pos:to_cursor())
        else
          MultiCursor.set(pos)
        end
      end
    end
    MultiCursor.toggle_follow(0, true)
    await_set_repeat(function()
      MultiCursor.actions.rotate_operator(dir, count, atom)
    end)
  end)
end

MultiCursor.actions.align = function()
  if MultiCursor.is_cascading() then
    return
  end
  local mcursors, primary = MultiCursor.get_all(0)
  ---@param mc MultiCursor.Entry
  local rightmost = vim.iter(mcursors):fold(primary, function(max, mc)
    return mc.start_col >= max.start_col and mc or max
  end)
  for _, mc in ipairs(mcursors) do
    local delta = rightmost.start_col - mc.start_col
    if delta > 0 then
      local pad = string.rep(" ", delta)
      vim.api.nvim_buf_set_text(0, mc.start_row, mc.start_col, mc.start_row, mc.start_col, { pad })
    end
  end
  MultiCursor.toggle_follow(0, true)
end

-- [Not implemented]
-- NOTE: See https://github.com/neovim/neovim/issues/42258
MultiCursor.actions.split_visual = function()
  --
end

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
vim.keymap.set({ "n", "x" }, "gm", function() MultiCursor.actions.cword_operator() end, { desc = "Cursors: match cword (operator)" })
vim.keymap.set({ "n", "x" }, "gM", function() MultiCursor.actions.search_operator() end, { desc = "Cursors: search (operator)" })
vim.keymap.set("n", "<Leader><leader>A", function() MultiCursor.actions.align() end, { desc = "Cursors: align" })
