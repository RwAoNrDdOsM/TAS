local mod = get_mod("TAS")

return {
	name = "TAS",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{ -- Record Key Keybind Toggle
				setting_id      = "record_key",
				type            = "keybind",
				default_value   = {},
				keybind_global  = true,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "record_key",
			},
			{-- Play Key Keybind Toggle
				setting_id      = "play_key",
				type            = "keybind",
				default_value   = {},
				keybind_global  = true,
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "play_key",
			}
		},
	}
}
