-- Queue entities to spawn at certain ticks -- mewmew
-- Add entities via .add_to_queue(tick, surface, entity_data, non_colliding_position_search_radius)
-- Example Esq.add_to_queue(3486, game.surfaces.nauvis, {name = "small-biter", position = {16, 17}, force = "player"}, false)

local Event = require("utils.event")
local Global = require("utils.global")

local table_insert = table.insert

local Public = {}

local ESQ = {}
Global.register(ESQ, function(tbl)
	ESQ = tbl
end)

local function spawn_entity(surface_index, entity_data, non_colliding_position_search_radius)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:16')
	local surface = game.surfaces[surface_index]
	if not surface then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:19')
		return
	end
	if not surface.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:22')
		return
	end
	if non_colliding_position_search_radius then
		local p = surface.find_non_colliding_position(
			entity_data.name,
			entity_data.position,
			non_colliding_position_search_radius,
			0.5
		)
		if p then
			entity_data.position = p
		end
	end
	surface.create_entity(entity_data)
end

function Public.add_to_queue(tick, surface, entity_data, non_colliding_position_search_radius)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:38')
	if not surface then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:40')
		return
	end
	if not surface.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:43')
		return
	end
	if not entity_data then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:46')
		return
	end
	if not entity_data.position then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:49')
		return
	end
	if not entity_data.name then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:52')
		return
	end
	if not tick then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:55')
		return
	end

	local queue = ESQ.queue
	local entity = {}

	for k, v in pairs(entity_data) do
		entity[k] = v
	end

	tick = tostring(tick)
	if not queue[tick] then
		queue[tick] = {}
	end
	table_insert(queue[tick], { surface.index, entity, non_colliding_position_search_radius })
end

local function on_tick()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:72')
	local tick = tostring(game.tick)
	if not ESQ.queue[tick] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:75')
		return
	end
	for _, v in pairs(ESQ.queue[tick]) do
		spawn_entity(v[1], v[2], v[3])
	end
	ESQ.queue[tick] = nil
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:83')
	ESQ.queue = {}
end

Event.on_init(on_init)
Event.add(defines.events.on_tick, on_tick)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/entity_spawn_queue.lua:90')
return Public
