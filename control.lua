require("defines")
require("util")
local helpers = require("helpers")


--the trigger to do stuff
script.on_event(defines.events.on_train_changed_state, function (event)
	local trigger = event.train
	--game.players[1].print("state changed to " .. trigger.state)

	--ensure train is ok
	if not trigger or not trigger.valid then
		return
	end

	--Delete trains that reach a deleteStop
	if trigger.state == defines.train_state.wait_station and trigger.station and trigger.station.name == AutomaticTrainDeployment_defines.names.entities.deleteStop then
		for _, cart in pairs(trigger.carriages) do
			cart.destroy()
		end

	--is a train heading to a copy/dandom stop?
	elseif trigger.state == defines.train_state.on_the_path and trigger.path_end_stop and trigger.path_end_stop.valid and
		(trigger.path_end_stop.name == AutomaticTrainDeployment_defines.names.entities.copyStop or 
		trigger.path_end_stop.name == AutomaticTrainDeployment_defines.names.entities.randomStop) then

		local trigger_stop = trigger.path_end_stop
		local source, source_stop = helpers.find_source_train(trigger_stop)

		if source == nil then
			--game.players[1].print("no source train")
			return
		end
		--game.players[1].print("train!")

		if not helpers.copy_rolling_stock(source, source_stop, trigger_stop) then
			return --no new train was created don't mess with existing ones
		end

		--find the newly created train
		local new = helpers.train_by_station(trigger_stop)

		--abort if no train was created
		if new == nil then
			--game.players[1].print("no train was created")
			return
		end

		--randomize the schedule?
		if trigger_stop.name == AutomaticTrainDeployment_defines.names.entities.randomStop then
			new.schedule = helpers.randomize_schedule(source)
		end

		--allows train auto mode and speed (does not work well with auto) to be set by signals
		local green = trigger_stop.get_circuit_network(defines.wire_type.green)
		local red = trigger_stop.get_circuit_network(defines.wire_type.red)

		local auto = ((green and green.get_signal{ type = "virtual", name = "signal-A"}) or 0) + ((red and red.get_signal{ type = "virtual", name = "signal-A"}) or 0)
		local speed = ((green and green.get_signal{ type = "virtual", name = "signal-S"}) or 0) + ((red and red.get_signal{ type = "virtual", name = "signal-S"}) or 0)

		--set the train to automatic
		new.manual_mode = auto <= 0
		new.speed = (speed > 0 and speed) or 0
	end
end)

--varoius console commands I used to debug things
--/c game.player.selected.connect_rolling_stock(defines.rail_direction.front)
--/c game.player.print(game.player.selected.train.state)
--/c game.player.print(game.player.selected.train.path_end_stop)
--/c game.player.print(game.player.selected.direction)
--/c game.player.print(game.player.surface.find_entities_filtered{force = game.player.force, position = {x = 5, y = -9}, type = "locomotive"})
--/c game.player.print(game.player.selected.burner.currently_burning)
--/c game.player.print(game.player.selected.get_control_behavior().disabled
--/c game.player.print(game.player.selected.train.front_stock == game.player.selected)
--/c game.player.print(game.player.selected.circuit_connection_definitions[1].target_circuit_id)