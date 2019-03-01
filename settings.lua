require("defines")

data:extend({
   {
      type = "string-setting",
      name = AutomaticTrainDeployment_defines.names.settings.circuitAuto,
      setting_type = "runtime-global",
      default_value = "Auto",
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
      default_value = true
   },
   {
      type = "bool-setting",
      name = AutomaticTrainDeployment_defines.names.settings.quickDelete,
      setting_type = "runtime-global",
      default_value = true
   }
})