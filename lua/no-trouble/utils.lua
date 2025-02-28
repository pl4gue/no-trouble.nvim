---@class no-trouble.utils
local M = {}

--- gets the current window, it's buffer (if none gets the current one) 
--- and the cursor position in it.
---@return integer
---@return integer
---@return no-trouble.pos
function M:get_win_buf_cursor()
	local win = vim.api.nvim_get_current_win() or 0
	local buf = vim.api.nvim_win_get_buf(win) or vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(win) or { 1, 0 }

  return win, buf, cursor
end

return M
