-- Input devices.

hl.config({
	input = {
		kb_layout  = "fr,us",
		kb_variant = "",
		kb_model   = "",
		kb_options = "grp:win_space_toggle",
		kb_rules   = "",

		follow_mouse = 1,

		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.device({
	name        = "logitech-g903-1",
	sensitivity = -0.3,
})
