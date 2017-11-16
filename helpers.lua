local public = {}

--offset from train stop to first cart
local offset = {}
offset[defines.direction.north] = {x = -2, y = 3}
offset[defines.direction.east] = {x = -3, y = -2}
offset[defines.direction.south] = {x = 2, y = -3}
offset[defines.direction.west] = {x = 3, y = 2}

--dostance to next cart
local per_cart_offset = {}
per_cart_offset[defines.direction.north] = {x = 0, y = 7}
per_cart_offset[defines.direction.east] = {x = -7, y = 0}
per_cart_offset[defines.direction.south] = {x = 0, y = -7}
per_cart_offset[defines.direction.west] = {x = 7, y = 0}

--opposite direction, for backwards locos
local opposite = {}
opposite[defines.direction.north] = defines.direction.south
opposite[defines.direction.south] = defines.direction.north
opposite[defines.direction.west] = defines.direction.east
opposite[defines.direction.east] = defines.direction.west

--convert from orientation to direction
local orientation_to_direction = {}
orientation_to_direction[0] = defines.direction.north
orientation_to_direction[0.25] = defines.direction.east
orientation_to_direction[0.5] = defines.direction.south
orientation_to_direction[0.75] = defines.direction.west

--return the train that could be at the station
function public.train_by_station(station)
	--is a train at valid position?
	for _, candidate in pairs(station.surface.find_entities_filtered{force = station.force, position = {x = station.position.x + offset[station.direction].x, y = station.position.y + offset[station.direction].y}}) do
		if candidate.train then
			return candidate.train
		end
	end

	return nil
end

local function square_dist(a, b)
	return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)
end

--creates a copy of the carts in a train at target train stop, returns true if at least one cart was copied
function public.copy_rolling_stock (orig, orig_stop, target)
	--place the train so it looks parked at the stop
	local pos = {x = target.position.x + offset[target.direction].x, y = target.position.y + offset[target.direction].y}
	local first = true
	local created = false

	local start = 1
	local fin = #orig.carriages
	local step = 1

	--is train backwards?
	if square_dist(orig.front_rail.position, orig_stop.position) > square_dist(orig.back_rail.position, orig_stop.position) then
		--game.players[1].print("source is backwards")
		start = #orig.carriages
		fin = 1
		step = -1
	end

	--game.players[1].print("start = " .. start .. " fin = " .. fin .. " step = " .. step)

	--copy each cart
	for idx = start, fin, step do
		--game.players[1].print("tried to place at " .. pos.x .. " , " .. pos.y)
		cart = orig.carriages[idx]
		--is cart backwards?
		local dir = (orientation_to_direction[cart.orientation] == orig_stop.direction and target.direction) or opposite[target.direction]
		--make new cart
		local new = target.surface.create_entity{name = cart.name, position = pos, direction = dir, force = target.force}

		--abort if placement failed
		if new == nil then
			return created
		end

		created = true

		--also copy fuel if loco
		if new.type == "locomotive" then
			for k,v in pairs(cart.get_fuel_inventory().get_contents()) do
				new.get_fuel_inventory().insert({name = k, count = v})
			end

			--copy burning fuel if any
			if cart.burner.currently_burning ~= nil then
				new.burner.currently_burning = cart.burner.currently_burning.name
				new.burner.remaining_burning_fuel = cart.burner.remaining_burning_fuel
			end
		end

		--copy color/filers/schedule/etc
		new.copy_settings(cart)

		--copy cargo if applicable
		local o_inv = cart.get_inventory(defines.inventory.cargo_wagon)
		if o_inv and not o_inv.is_empty() then
			local n_inv = new.get_inventory(defines.inventory.cargo_wagon)
			for item, num in pairs(o_inv.get_contents()) do
				n_inv.insert{name = item, count = num}
			end
		end

		--copy fluidbox if applicable
		if cart.fluidbox then
			for idx=1,#cart.fluidbox,1 do
				new.fluidbox[idx] = cart.fluidbox[idx]
			end
		end
		
		--update positon for next cart
		pos.x = pos.x + per_cart_offset[target.direction].x
		pos.y = pos.y + per_cart_offset[target.direction].y
	end

	return created
end

--creates a new schedule by randomly choosing a stop from the old one (excluding the read stop)
function public.randomize_schedule (orig)
	local schedule = table.deepcopy(orig.schedule)

	--train without locomotives
	if schedule == nil then
		return
	end

	local weights = {}
	local tot = 0

	--get the weights for different stations
	for idx,rec in pairs(schedule.records) do
		weights[idx] = (rec.wait_conditions and rec.wait_conditions[1] and rec.wait_conditions[1].condition and rec.wait_conditions[1].condition.constant) or 100
		tot = tot + weights[idx]
	end

	--abort if no entries left
	if tot == 0 then
		return shcedule
	end

	-- get a random number between 1 and total weight
	local sel = math.random(1, tot)
	tot = 0

	--select the station that makes the total weight greater than the random number
	for idx,w in pairs(weights) do
		tot = tot + w
		if sel <= tot then
			schedule.current = idx
			return schedule
		end
	end

	return schedule
end

--breadth first search over network color
local function bfs(source, color, source_id)
	local front = {{ent = source, id = source_id or 1}}
	local visited = {}
	local next = {}
	local res = {}

	--wihle there are nodes to visit
	while #front > 0 do
		next = {}

		--visit all nodes on perimiter
		for _, node in ipairs(front) do
			if not visited[node.ent.position.y] then
				visited[node.ent.position.y] = {}
			end
		
			if not visited[node.ent.position.y][node.ent.position.x] then
				visited[node.ent.position.y][node.ent.position.x] = {}
			end

			--is this a new node?
			if not visited[node.ent.position.y][node.ent.position.x][node.id] then
				visited[node.ent.position.y][node.ent.position.x][node.id] = true
				table.insert(res, node.ent)

				--add not already visited neighbours
				for _, def in ipairs(node.ent.circuit_connection_definitions) do
					--make sure soirce id is correct (important for combinators) and that the neighbour has not already been visited
					if def.source_circuit_id == node.id and def.wire == color and not (visited[def.target_entity.position.y] and visited[def.target_entity.position.y][def.target_entity.position.x] and visited[def.target_entity.position.y][def.target_entity.position.x][def.target_circuit_id]) then
						table.insert(next, {ent = def.target_entity, id = def.target_circuit_id})
					end
				end
			end
		end
		front = next
	end

	--game.players[1].print(color .. " BFS found " .. #res .. " entires.")
	return res
end

--returns all entities in the circuit networks source belongs to in a table with arrays for red and green
local function get_all_circuit_connected_entities(source)
	return {red = bfs(source, defines.wire_type.red), green = bfs(source,  defines.wire_type.green)}
end

--looks within a circuit network for read stops, returns train parked at stop and stop
local function fst_helper(network)
	--search entities in network
	for _, ent in pairs(network) do
		if ent.name == AutomaticTrainDeployment_defines.names.entities.readStop and ent.get_control_behavior().disabled == false then
			--game.players[1].print("Input stop found")
			local candidate = public.train_by_station(ent)

			if candidate then
				--game.players[1].print("Valid train found")
				return candidate, ent
			end
		end
	end
	--no valid train found in network
	return nil
end

--searches for a train waiting at a read stop connected by red/green wire, returns train and stop if found
function public.find_source_train(station)
	local networks = get_all_circuit_connected_entities(station)
	local train, station = fst_helper(networks.red)
	if train then
		--game.players[1].print("Returning valid green train")
		return train, station
	end
	return fst_helper(networks.green)
end

return public