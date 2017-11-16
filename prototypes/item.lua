require("util")

--[[ {
    type = "item",
    name = "train-stop",
    icon = "__base__/graphics/icons/train-stop.png",
    flags = {"goes-to-quickbar"},
    subgroup = "transport",
    order = "a[train-system]-c[train-stop]",
    place_result = "train-stop",
    stack_size = 10
  },
--]]

local deleteStop = table.deepcopy(data.raw.item["train-stop"])
deleteStop.name = AutomaticTrainDeployment_defines.names.items.deleteStop
deleteStop.place_result = AutomaticTrainDeployment_defines.names.entities.deleteStop
deleteStop.order = "z-a"

local readStop = table.deepcopy(data.raw.item["train-stop"])
readStop.name = AutomaticTrainDeployment_defines.names.items.readStop
readStop.place_result = AutomaticTrainDeployment_defines.names.entities.readStop
readStop.order = "z-b"

local copyStop = table.deepcopy(data.raw.item["train-stop"])
copyStop.name = AutomaticTrainDeployment_defines.names.items.copyStop
copyStop.place_result = AutomaticTrainDeployment_defines.names.entities.copyStop
copyStop.order = "z-c"

local randomStop = table.deepcopy(data.raw.item["train-stop"])
randomStop.name = AutomaticTrainDeployment_defines.names.items.randomStop
randomStop.place_result = AutomaticTrainDeployment_defines.names.entities.randomStop
randomStop.order = "z-d"


data:extend({deleteStop, readStop, copyStop, randomStop})