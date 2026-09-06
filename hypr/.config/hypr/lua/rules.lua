-- Window / layer rules + xwayland.

hl.layer_rule({
	name = "blur-apps-bg",
	match = { namespace = "waybar|rofi" },
	blur = true,
	xray = true,
	ignore_alpha = false,
})

hl.layer_rule({
	name = "qs-blur",
	match = {
		namespace = "^(quickshell|qs).*",
	},
	blur = true,
	xray = true,
	blur_popups = true,
	ignore_alpha = 0.3,
})

hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
})

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})
