hl.monitor({ output = "", mode = "preferred", position = "auto-up", scale = "1" })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = "1.5" })

local M = {}

local function activeOffset()
	local mon = hl.get_active_monitor()
	if not mon or mon.name == "eDP-1" then
		return 0
	end

	local index = tonumber(mon.name:match("(%d+)$")) or 0
	local base = mon.name:match("^HDMI") and 50 or 0
	return base + index * 10
end

function M.focusWorkspace(n)
	return function()
		hl.dispatch(hl.dsp.focus({ workspace = activeOffset() + n }))
	end
end

function M.moveToWorkspace(n)
	return function()
		hl.dispatch(hl.dsp.window.move({ workspace = activeOffset() + n, follow = false }))
	end
end

return M
