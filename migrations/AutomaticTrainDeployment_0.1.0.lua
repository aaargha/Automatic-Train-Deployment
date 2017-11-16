require("util")

--offset from train stop to first cart
local offset = {}
offset[defines.direction.north] = {x = -2, y = 3}
offset[defines.direction.east] = {x = -3, y = -2}
offset[defines.direction.south] = {x = 2, y = -3}
offset[defines.direction.west] = {x = 3, y = 2}

--return the train that could be at the station
local function train_by_station(station)
	--is a train at valid position?
	for _, candidate in pairs(station.surface.find_entities_filtered{force = station.force, position = {x = station.position.x + offset[station.direction].x, y = station.position.y + offset[station.direction].y}, type = "locomotive"}) do
		--game.players[1].print("found loco")
		return candidate.train
	end

	for _, candidate in pairs(station.surface.find_entities_filtered{force = station.force, position = {x = station.position.x + offset[station.direction].x, y = station.position.y + offset[station.direction].y}, type = "cargo-wagon"}) do
		--game.players[1].print("found cargo")
		return candidate.train
	end

	for _, candidate in pairs(station.surface.find_entities_filtered{force = station.force, position = {x = station.position.x + offset[station.direction].x, y = station.position.y + offset[station.direction].y}, type = "fluid-wagon"}) do
		--game.players[1].print("found fluid")
		return candidate.train
	end

	return nil
end

--move all source trains from the old way of doing things to the new
--tries to find all valid source trains and removes the current destination from the schedule
for _, surface in pairs(game.surfaces) do
	for _, station in ipairs(surface.find_entities_filtered{name = "AutomaticTrainDeployment-read-stop"}) do
		local train = train_by_station(station)
		if train then
			local schedule = table.deepcopy(train.schedule)
			table.remove(schedule.records, schedule.current)
			schedule.current = 1
			train.schedule = schedule
			train.manual_mode = true
		end
	end
end

for _,player in pairs(game.connected_players) do
	player.print("Automatic train deployment: important changes from previous version:")
	player.print("Source trains should no longer be parked at the input stops, and only stops that should be on the schedule of the new train should be in the schedule.")
	player.print("As to make sure that existing setups still work the schedules of all correctly placed source trains have been updated to remove the entry for the input stop.")
	player.print("For further details please see the forum thread")
end