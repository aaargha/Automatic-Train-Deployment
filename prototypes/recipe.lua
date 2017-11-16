require("util")

local deleteStop = table.deepcopy(data.raw.recipe["train-stop"])
deleteStop.name = AutomaticTrainDeployment_defines.names.recipes.deleteStop
deleteStop.result = AutomaticTrainDeployment_defines.names.items.deleteStop

local readStop = table.deepcopy(data.raw.recipe["train-stop"])
readStop.name = AutomaticTrainDeployment_defines.names.recipes.readStop
readStop.result = AutomaticTrainDeployment_defines.names.items.readStop

local copyStop = table.deepcopy(data.raw.recipe["train-stop"])
copyStop.name = AutomaticTrainDeployment_defines.names.recipes.copyStop
copyStop.result = AutomaticTrainDeployment_defines.names.items.copyStop

local randomStop = table.deepcopy(data.raw.recipe["train-stop"])
randomStop.name = AutomaticTrainDeployment_defines.names.recipes.randomStop
randomStop.result = AutomaticTrainDeployment_defines.names.items.randomStop

data:extend({deleteStop, readStop, copyStop, randomStop})