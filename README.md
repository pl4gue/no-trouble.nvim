# no-trouble.nvim

Jump between workspace diagnostics with no trouble!

## Motivation

My hate for the [trouble](https://github.com/folke/trouble.nvim) window opening everytime I jumped
diagnostics, and the lack of a way to automatically closing it without getting a bunch of errors on
my face. Also the fact that no other plugin seems to be able to jump workspace diagnostics, only
document ones.

## Installation

Add `pl4gue/no-trouble.nvim` to your plugin manager and call:

```lua
require('no-trouble').setup()
```

and start using `[d` and `]d` to jump between your diagnostics.

### Configuration

You can also tweak your experience by configuring the plugin on setup. Refer to the following lua
table bellow:

```lua
local defaults = {
	-- should cycle when reaching last or first
	cycle = true,

	-- should open diagnostics float after jumping
	open_float = true,

	-- should the item to jump to be calculated based on cursor position or
	-- remember the last diagnostic jumped to
	follow_cursor = true,

	mappings = {
		["[d"] = "prev",
		["]d"] = "next",
	},
}
```

## API

**no-trouble** provides a very open API, that gives you the power to hack it however you like.

The most useful parts of it are listed bellow, and more might be coming in the future.

```lua
--- @class no-trouble
--- @field diags no-trouble.Diagnostic[]
--- @field actions no-trouble.Actions
--- @field config no-trouble.cfg
local no_trouble = require('no-trouble')

-- List containing all workspace diagnostics
no_trouble.diags

-- Current configuration, can be used to dynamically set and get the current 
-- used options
no_trouble.config

-- List of possible actions to take, can't be extended now
no_trouble.actions

--- performs the setup of the plugin with the given options
--- @param opts? no-trouble.cfg
no_trouble.setup(opts)

--- jumps to next diagnostic following the config rules
no_trouble.actions.next()

--- jumps to previous diagnostic following the config rules
no_trouble.actions.prev()

--- sorts a given no-trouble.Diagnostic table or the main one if none are given
--- @param tbl? no-trouble.Diagnostic[]
no_trouble:sort(tbl)

--- given a buffer and a position returns the 2 closest diagnostics that can be jumped to
--- both can separately be nil if there's no possible diagnostic that meet the criteria 
--- following the plugin's config and the existence of diagnostics on valid buffers
--- @param buf number
--- @param cursor no-trouble.pos
--- @return no-trouble.Diagnostic?, no-trouble.Diagnostic?
no_trouble:get_neighbor_diagnostics(buf, cursor)

--[[ 
    these are some helper functions that aren't focused on the plugin 
    functionality but I needed to use :/ 
]]

local no_trouble.utils = require('no-trouble.utils')

--- gets the current window, it's buffer (if none gets the current one) 
--- and the cursor position in it.
--- @return integer
--- @return integer
--- @return no-trouble.pos
no_trouble.utils:get_win_buf_cursor()
```

## To Do

- [ ] Make a way to filter the diagnostics it should jump to.
- [ ] Stabilize the API a bit more, letting users better hack it while maintaining needed parts away from it.
- [ ] Modularize the code so it can be used with other types of items, not only diagnostics.
