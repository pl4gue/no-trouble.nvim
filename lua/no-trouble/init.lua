local Diag = require("no-trouble.diagnostics")

--- @alias no-trouble.action fun(config: no-trouble.cfg)
--- @alias no-trouble.Actions {next: no-trouble.action, prev: no-trouble.action}

---@class no-trouble
---@field diags no-trouble.Diagnostic[]
---@field actions no-trouble.Actions
---@field config no-trouble.cfg
local M = {
	diags = {},
	actions = {},
}

---@type no-trouble.Diagnostic
local last_jumped

---@param opts? no-trouble.cfg
function M.setup(opts)
	M.config = require("no-trouble.config").setup(opts)

	M:create_autocmd_and_populate()
	M:set_mappings()
end

function M:create_autocmd_and_populate()
	vim.api.nvim_create_autocmd("DiagnosticChanged", {
		group = vim.api.nvim_create_augroup("no-trouble.diagnostic_update", { clear = true }),
		callback = function(_)
			M.diags = vim.tbl_map(Diag.from_diagnostic, vim.diagnostic.get())
			M.diags = M:sort()
		end,
	})

	for _, diag in ipairs(vim.diagnostic.get()) do
		if diag.bufnr and vim.api.nvim_buf_is_valid(diag.bufnr) then
			M.diags = M.diags or {}
			table.insert(M.diags, Diag.from_diagnostic(diag))
		end
	end

  M.diags = M:sort()
end

function M:set_mappings()
	for key, action in pairs(M.config.mappings) do
		if M.actions[action] then
			vim.keymap.set("n", key, M.actions[action])
		end
	end
end

---@param tbl? no-trouble.Diagnostic[]
function M:sort(tbl)
  tbl = tbl or M.diags

	table.sort(tbl, function(a, b)
		if a.buf ~= b.buf then
			return a.buf < b.buf
		end

		if a.pos[1] ~= b.pos[1] then
			return a.pos[1] < b.pos[1]
		end

		return a.pos[2] < b.pos[2]
	end)

  return tbl
end

function M.actions.prev()
	local win = vim.api.nvim_get_current_win() or 0
	local buf = vim.api.nvim_win_get_buf(win) or vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(win) or { 1, 0 }

	local prev, _ = M:get_neighbor_diagnostics(buf, cursor)

  if not prev then return end

  Diag.goto(prev, win)

  if M.config.open_float then
    vim.diagnostic.open_float()
  end
end


function M.actions.next()
	local win = vim.api.nvim_get_current_win() or 0
	local buf = vim.api.nvim_win_get_buf(win) or vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(win) or { 1, 0 }

	local _, next = M:get_neighbor_diagnostics(buf, cursor)

  if not next then return end

  Diag.goto(next, win)

  if M.config.open_float then
    vim.diagnostic.open_float()
  end
end

---@param buf number
---@param cursor {[1]: number, [2]: number}
---@return no-trouble.Diagnostic?, no-trouble.Diagnostic?
function M:get_neighbor_diagnostics(buf, cursor)
  local diags = vim.tbl_filter(function (d) return not (d.buf == buf and d.pos[1] == cursor[1]) end, M.diags)
  local cur_idx = nil

  if M.config.follow_cursor then
    table.insert(diags, { current_cursor = true, buf = buf, pos = cursor})
  end

  diags = M:sort(diags)

  for i, value in ipairs(diags) do
    if (M.config.follow_cursor and value['current_cursor']) or (not M.config.follow_cursor and value == last_jumped) then
      cur_idx = i
      break
    end
  end

  local prev_idx, next_idx

  if M.config.cycle then
    prev_idx = cur_idx - 1 ~= 0 and cur_idx - 1 or #diags
    next_idx = cur_idx + 1 ~= #diags + 1 and cur_idx + 1 or 1
  else
    prev_idx = cur_idx - 1 ~= 0 and cur_idx - 1 or nil
    next_idx = cur_idx + 1 ~= #diags + 1 and cur_idx + 1 or nil
  end

  local prev = prev_idx and diags[prev_idx] or nil
  local next = next_idx and diags[next_idx] or nil

  return prev, next
end

return M
