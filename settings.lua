require("defines")

data:extend({
   {
      type = "string-setting",
      name = AutomaticTrainDeployment_defines.names.settings.circuitAuto,
      setting_type = "runtime-global",
      default_value = "A > 0",
	  allowed_values = 
	  {
		"Auto",
		"A > 0",
		"Manual"
	  }
   },
   {
      type = "bool-setting",
      name = AutomaticTrainDeployment_defines.names.settings.circuitSpeed,
      setting_type = "runtime-global",
      default_value = false
   },
   {
      type = "bool-setting",
      name = AutomaticTrainDeployment_defines.names.settings.quickDelete,
      setting_type = "runtime-global",
      default_value = false
   }
})