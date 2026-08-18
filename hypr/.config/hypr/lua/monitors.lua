hl.monitor({ output = "eDP-1", mode = "1920x1080", position = "0x0",     scale = "1.5" })
hl.monitor({ output = "DP-5",  mode = "1920x1080", position = "0x-1080", scale = "1" })
hl.monitor({ output = "DP-3",  mode = "1920x1080", position = "auto",    scale = "1.5" })
hl.monitor({ output = "DP-1",  mode = "1920x1080", position = "0x-1080", scale = "1" })
hl.monitor({ output = "DP-4",  mode = "1920x1080", position = "0x-1080", scale = "1" })
hl.monitor({ output = "DP-2",  mode = "1920x1080", position = "0x-1080", scale = "1" })

local M = {}

local OFFSETS = {
	["eDP-1"] = 0,
	["DP-1"]  = 10,
	["DP-2"]  = 20,
	["DP-3"]  = 30,
	["DP-4"]  = 40,
	["DP-5"]  = 50,
}

local function activeOffset()
	local mon = hl.get_active_monitor()
	if not mon then
		return 0
	end
	return OFFSETS[mon.name] or 0
end

function M.focusWorkspace(n)
	return function()
		hl.dispatch(hl.dsp.focus({ workspace = activeOffset() + n }))
	end
end

-- Move the active window to workspace `n` of the currently focused
-- monitor, without following it (mirrors the old movetoworkspacesilent).
function M.moveToWorkspace(n)
	return function()
		hl.dispatch(hl.dsp.window.move({ workspace = activeOffset() + n, silent = true }))
	end
end

return M
