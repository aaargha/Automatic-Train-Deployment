require("util")

local technology = table.deepcopy(data.raw.technology["automated-rail-transportation"])
technology.name = AutomaticTrainDeployment_defines.names.technology
technology.effects = 
{
	{
		type = "unlock-recipe",
		recipe = AutomaticTrainDeployment_defines.names.recipes.deleteStop
	},
	{
		type = "unlock-recipe",
		recipe = AutomaticTrainDeployment_defines.names.recipes.readStop
	},
	{
		type = "unlock-recipe",
		recipe = AutomaticTrainDeployment_defines.names.recipes.copyStop
	},
	{
		type = "unlock-recipe",
		recipe = AutomaticTrainDeployment_defines.names.recipes.randomStop
	}
}
technology.prerequisites = {"automated-rail-transportation","circuit-network"}

data:extend({technology})