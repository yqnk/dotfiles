-- Look and feel: general, decoration, animations, misc.
-- stole the animation curves, credits to luyu-wu

hl.config({
	general = {
		gaps_in  = 2,
		gaps_out = 4,

		border_size = 1,

		col = {
			active_border   = { colors = { "rgba(414551aa)", "rgba(4b5b75aa)" }, angle = 45 },
			inactive_border = "rgba(33333333)",
		},

		resize_on_border = true,
		allow_tearing    = false,

		layout = "dwindle",
	},

	decoration = {
		rounding       = 2,
		rounding_power = 2,

		active_opacity   = 1,
		inactive_opacity = 1,

		shadow = {
			enabled      = false,
			range        = 4,
			render_power = 3,
			color        = "rgba(1a1a1aee)",
		},

		blur = {
			enabled            = true,
			size               = 6,
			passes             = 3,
			new_optimizations  = true,
			ignore_opacity     = true,
		},
	},

	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo   = true,
	},
})

hl.curve("fluent_decel",   { type = "bezier", points = { { 0, 0.2 },    { 0.4, 1 } } })
hl.curve("easeOutCirc",    { type = "bezier", points = { { 0, 0.55 },   { 0.45, 1 } } })
hl.curve("easeOutCubic",   { type = "bezier", points = { { 0.33, 1 },   { 0.68, 1 } } })
hl.curve("easeinoutsine",  { type = "bezier", points = { { 0.37, 0 },   { 0.63, 1 } } })

hl.animation({ leaf = "windowsIn",  enabled = true, speed = 3,   bezier = "easeOutCubic",  style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3,   bezier = "easeOutCubic",  style = "slide" })
hl.animation({ leaf = "windows",    enabled = true, speed = 2.5, bezier = "easeinoutsine", style = "slide" }) -- move/drag/resize
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 2,   bezier = "easeOutCubic" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 2,   bezier = "easeOutCubic" })
hl.animation({ leaf = "fadeDim",    enabled = true, speed = 6,   bezier = "fluent_decel" })
hl.animation({ leaf = "border",     enabled = true, speed = 2.7, bezier = "easeOutCirc" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3,   bezier = "fluent_decel", style = "slidefadevert 5%" })
