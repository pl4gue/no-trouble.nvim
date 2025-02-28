---@class no-trouble.cfg.mod: no-trouble.cfg
local M = {}

---@class no-trouble.cfg
local defaults = {
	-- cycle when jumping to previous when on first or next when on last
	cycle = true,

	-- should open diagnostics float after jumping
	open_float = true,

	-- should the current item be the closest to the cursor or should it
	-- remember the last diagnostic jumped from
	follow_cursor = true,

	mappings = {
		["[d"] = "prev",
		["]d"] = "next",
	},
}

---@type no-trouble.cfg
local options

---@param opts? no-trouble.cfg
function M.setup(opts)
	options = vim.tbl_deep_extend("force", defaults, opts or {})
	return options
end

return setmetatable(M, {
	__index = function(_, k)
		options = options or M.setup()
		return options[k]
	end,
})
