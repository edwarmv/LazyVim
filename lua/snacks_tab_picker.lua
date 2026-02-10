local Snacks = require("snacks")

local M = {}

local function get_tab_buffers()
  local items = {}
  local labels = {}
  local tabpages = vim.api.nvim_list_tabpages()
  for i, tabpage in ipairs(tabpages) do
    local wins = vim.api.nvim_tabpage_list_wins(tabpage)
    local seen = {}
    for _, win in ipairs(wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      if not seen[buf] then
        seen[buf] = true
        if vim.fn.buflisted(buf) == 0 then
          goto continue
        end
        local bufname = vim.api.nvim_buf_get_name(buf)
        if bufname == "" then
          bufname = "[No Name]"
        end
        local display = vim.fn.fnamemodify(bufname, ":~:.")
        local preview_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        local label = ("Tab %d"):format(i)
        labels[#labels + 1] = label

        table.insert(items, {
          idx = i,
          label = label,
          file = display,
          text = label .. " " .. display,
          tabnr = i,
          tabpage = tabpage,
          winid = win,
          buf = buf,
          preview = {
            text = table.concat(preview_lines, "\n"),
            ft = ft,
          },
        })
        ::continue::
      end
    end
  end
  local max_width = 0
  for _, label in ipairs(labels) do
    max_width = math.max(max_width, vim.fn.strdisplaywidth(label))
  end
  if max_width > 0 then
    for _, item in ipairs(items) do
      local padding = max_width - vim.fn.strdisplaywidth(item.label)
      if padding > 0 then
        item.label = item.label .. string.rep(" ", padding)
      end
    end
  end
  return items
end

function M.tabs_picker()
  local items = get_tab_buffers()
  Snacks.picker({
    title = "Tab Buffers",
    items = items,
    format = "file",
    confirm = function(picker, item)
      picker:close()
      if vim.api.nvim_tabpage_is_valid(item.tabpage) then
        vim.api.nvim_set_current_tabpage(item.tabpage)
      end
      if item.winid and vim.api.nvim_win_is_valid(item.winid) then
        vim.api.nvim_set_current_win(item.winid)
      elseif item.buf and vim.api.nvim_buf_is_valid(item.buf) then
        vim.api.nvim_set_current_buf(item.buf)
      end
    end,
    preview = "preview",
    actions = {
      close_tab = function(picker, item)
        picker:close()
        vim.cmd(("tabclose %d"):format(item.tabnr))
      end,
    },
    win = {
      input = {
        keys = {
          ["d"] = "close_tab",
        },
      },
    },
  })
end

return M
