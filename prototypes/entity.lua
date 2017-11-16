require("util")

local deleteStop = table.deepcopy(data.raw["train-stop"]["train-stop"])
deleteStop.name = AutomaticTrainDeployment_defines.names.entities.deleteStop
deleteStop.minable = {mining_time = 1, result = AutomaticTrainDeployment_defines.names.items.deleteStop}

local readStop = table.deepcopy(data.raw["train-stop"]["train-stop"])
readStop.name = AutomaticTrainDeployment_defines.names.entities.readStop
readStop.minable = {mining_time = 1, result = AutomaticTrainDeployment_defines.names.items.readStop}

local copyStop = table.deepcopy(data.raw["train-stop"]["train-stop"])
copyStop.name = AutomaticTrainDeployment_defines.names.entities.copyStop
copyStop.minable = {mining_time = 1, result = AutomaticTrainDeployment_defines.names.items.copyStop}

local randomStop = table.deepcopy(data.raw["train-stop"]["train-stop"])
randomStop.name = AutomaticTrainDeployment_defines.names.entities.randomStop
randomStop.minable = {mining_time = 1, result = AutomaticTrainDeployment_defines.names.items.randomStop}

data:extend({deleteStop, readStop, copyStop, randomStop})