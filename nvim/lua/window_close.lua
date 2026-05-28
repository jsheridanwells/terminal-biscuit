-- ── Window/file close model ─────────────────────────────────────────────
-- :q / :qa  → always quit Neovim
-- :x        → close focused window (if several) else close current file
-- :xa       → collapse to one blank editor, keep neo-tree, never quit

local function real_wins()
  local t = {}
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(w).relative == "" then
      local b = vim.api.nvim_win_get_buf(w)
      if vim.bo[b].buftype == "" then t[#t + 1] = w end
    end
  end
  return t
end

local function is_blank(buf)
  if vim.api.nvim_buf_get_name(buf) ~= "" then return false end
  if vim.bo[buf].modified then return false end
  local l = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return #l <= 1 and (l[1] or "") == ""
end

vim.api.nvim_create_user_command("CloseWin", function()
  local cur = vim.api.nvim_get_current_win()
  local curbuf = vim.api.nvim_win_get_buf(cur)
  -- focused on neo-tree / float / non-editor: do nothing
  if vim.bo[curbuf].buftype ~= "" or vim.api.nvim_win_get_config(cur).relative ~= "" then
    return
  end
  if #real_wins() >= 2 then
    vim.cmd("close")        -- several editor windows → close focused
  elseif not is_blank(curbuf) then
    vim.cmd("bdelete")      -- one window → close current file (next buffer or blank)
  end
  -- one blank window → nothing
end, {})

vim.api.nvim_create_user_command("CloseAll", function()
  local wins = real_wins()
  if #wins == 0 then return end

  local cur = vim.api.nvim_get_current_win()
  local keep = wins[1]
  for _, w in ipairs(wins) do if w == cur then keep = w end end

  for _, w in ipairs(wins) do            -- close other editor windows, leave neo-tree
    if w ~= keep and vim.api.nvim_win_is_valid(w) then
      vim.api.nvim_win_call(w, function() pcall(vim.cmd, "close") end)
    end
  end
  vim.api.nvim_set_current_win(keep)

  local file_bufs = {}
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if vim.bo[info.bufnr].buftype == "" then file_bufs[#file_bufs + 1] = info.bufnr end
  end

  -- already a lone blank editor → nothing
  if #wins == 1 and #file_bufs <= 1 and is_blank(vim.api.nvim_win_get_buf(keep)) then
    return
  end

  vim.cmd("enew")                        -- fresh blank in kept window
  local blank = vim.api.nvim_get_current_buf()
  for _, b in ipairs(file_bufs) do
    if b ~= blank and vim.api.nvim_buf_is_valid(b) then
      pcall(vim.cmd, "bdelete " .. b)
    end
  end
end, {})

local function cabbrev(lhs, rhs)
  vim.cmd(string.format(
    [[cnoreabbrev <expr> %s (getcmdtype() ==# ':' && getcmdline() ==# '%s') ? '%s' : '%s']],
    lhs, lhs, rhs, lhs
  ))
end
cabbrev("x", "CloseWin")
cabbrev("xa", "CloseAll")
cabbrev("q", "qa")   -- :q now quits everything, just like :qa
