---@alias no-trouble.pos {[1]: number, [2]: number}

--- @class no-trouble.Diagnostic
--- @field buf number
--- @field pos no-trouble.pos
--- @field severity vim.diagnostic.Severity
local M = {}


---@param diag no-trouble.Diagnostic
---@param win number
function M.goto(diag, win)
  win = win or vim.api.nvim_get_current_win()

  if not vim.api.nvim_buf_is_valid(diag.buf) then
    error('Tried jumping to invalid buffer')
  end

  vim.api.nvim_win_set_buf(win, diag.buf)
  vim.api.nvim_win_set_cursor(win, diag.pos)
end

---@param diag vim.Diagnostic
function M.from_diagnostic(diag)
  local self = {
    buf = diag.bufnr,
    pos =  {
      diag.lnum + 1,
      diag.col,
    },
    severity = diag.severity
  }

  assert(self.buf, 'diagnostic buffer required')
  assert(self.pos, 'diagnostic position required')

  return self
end

return M
