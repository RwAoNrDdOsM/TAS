return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`TAS` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("TAS", {
			mod_script       = "scripts/mods/TAS/TAS",
			mod_data         = "scripts/mods/TAS/TAS_data",
			mod_localization = "scripts/mods/TAS/TAS_localization",
		})
	end,
	packages = {
		"resource_packages/TAS/TAS",
	},
}
