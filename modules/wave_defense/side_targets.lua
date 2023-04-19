local WD = require("modules.wave_defense.table")
local Public = {}
local side_target_types = {
	["accumulator"] = true,
	["assembling-machine"] = true,
	["boiler"] = true,
	["furnace"] = true,
	["generator"] = true,
	["lab"] = true,
	["lamp"] = true,
	["mining-drill"] = true,
	["power-switch"] = true,
	["radar"] = true,
	["reactor"] = true,
	["roboport"] = true,
	["rocket-silo"] = true,
	["solar-panel"] = true,
}

local function get_random_target()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:19')
	local side_target_count = WD.get("side_target_count")
	local side_targets = WD.get("side_targets")
	local r = math.random(1, side_target_count)
	if not side_targets[r] then
		table.remove(side_targets, r)
		WD.set("side_target_count", side_target_count - 1)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:26')
		return
	end
	if not side_targets[r].valid then
		table.remove(side_targets, r)
		WD.set("side_target_count", side_target_count - 1)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:31')
		return
	end
	side_targets = WD.get("side_targets")
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:34')
	return side_targets[r]
end

function Public.get_side_target()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:37')
	local enable_side_target = WD.get("enable_side_target")
	if not enable_side_target then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:40')
		return
	end
	local side_target_count = WD.get("side_target_count")
	for _ = 1, 512, 1 do
		if side_target_count == 0 then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:45')
			return
		end
		local target = get_random_target()
		if target then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:49')
			return target
		end
	end
end

local function add_entity(entity)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:54')
	local enable_side_target = WD.get("enable_side_target")

	if not enable_side_target then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:58')
		return
	end

	local surface_index = WD.get("surface_index")
	--skip entities that are on another surface
	if entity.surface.index ~= surface_index then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:64')
		return
	end

	local side_target_count = WD.get("side_target_count")
	if side_target_count >= 512 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:69')
		return
	end

	local side_targets = WD.get("side_targets")
	--add entity to the side target list
	table.insert(side_targets, entity)
	WD.set("side_target_count", side_target_count + 1)
end

local function on_built_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:78')
	if not event.created_entity then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:80')
		return
	end
	if not event.created_entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:83')
		return
	end
	if not side_target_types[event.created_entity.type] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:86')
		return
	end
	add_entity(event.created_entity)
end

local function on_robot_built_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:91')
	if not event.created_entity then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:93')
		return
	end
	if not event.created_entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:96')
		return
	end
	if not side_target_types[event.created_entity.type] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:99')
		return
	end
	add_entity(event.created_entity)
end

local event = require("utils.event")
event.add(defines.events.on_built_entity, on_built_entity)
event.add(defines.events.on_robot_built_entity, on_robot_built_entity)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/side_targets.lua:108')
return Public
