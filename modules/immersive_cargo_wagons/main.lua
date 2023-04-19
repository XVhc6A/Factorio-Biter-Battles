local Global = require("utils.global")
local Event = require("utils.event")
local Functions = require("modules.immersive_cargo_wagons.functions")
local Public = {}

local math_round = math.round

local icw = {}
Global.register(icw, function(tbl)
	icw = tbl
end)

function Public.reset()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:12')
	if icw.surfaces then
		for k, surface in pairs(icw.surfaces) do
			if surface and surface.valid then
				game.delete_surface(surface)
			end
		end
	end
	for k, v in pairs(icw) do
		icw[k] = nil
	end
	icw.doors = {}
	icw.wagons = {}
	icw.trains = {}
	icw.players = {}
	icw.surfaces = {}
end

local function on_entity_died(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:30')
	local entity = event.entity
	if not entity and not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:33')
		return
	end
	Functions.subtract_wagon_entity_count(icw, entity)
	Functions.kill_wagon(icw, entity)
end

local function on_player_mined_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:39')
	local entity = event.entity
	if not entity and not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:42')
		return
	end
	Functions.subtract_wagon_entity_count(icw, entity)
	Functions.kill_wagon(icw, entity)
end

local function on_robot_mined_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:48')
	local entity = event.entity
	if not entity and not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:51')
		return
	end
	Functions.subtract_wagon_entity_count(icw, entity)
	Functions.kill_wagon(icw, entity)
end

local function on_built_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:57')
	local created_entity = event.created_entity
	Functions.create_wagon(icw, created_entity)
	Functions.add_wagon_entity_count(icw, created_entity)
end

local function on_robot_built_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:63')
	local created_entity = event.created_entity
	Functions.create_wagon(icw, created_entity)
	Functions.add_wagon_entity_count(icw, created_entity)
end

local function on_player_driving_changed_state(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:69')
	local player = game.players[event.player_index]
	Functions.use_cargo_wagon_door(icw, player, event.entity)
end

local function on_player_joined_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:74')
	local player_data = icw.players[event.player_index]
	if not player_data then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:77')
		return
	end

	local surface = game.surfaces[player_data.surface]
	if surface and surface.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:82')
		return
	end

	local fallback_surface = game.surfaces[player_data.fallback_surface]
	if not fallback_surface or not fallback_surface.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:87')
		return
	end

	local player = game.players[event.player_index]
	local p = fallback_surface.find_non_colliding_position("character", player_data.fallback_position, 32, 0.5)
	if p then
		player.teleport(p, fallback_surface)
	else
		player.teleport(player.force.get_spawn_position(fallback_surface), fallback_surface)
	end
end

local function on_player_left_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:99')
	Functions.kill_minimap(game.players[event.player_index])
end

local function on_gui_closed(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:103')
	local entity = event.entity
	if not entity then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:106')
		return
	end
	if not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:109')
		return
	end
	if not entity.unit_number then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:112')
		return
	end
	if not icw.wagons[entity.unit_number] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:115')
		return
	end
	Functions.kill_minimap(game.players[event.player_index])
end

local function on_gui_opened(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:120')
	local entity = event.entity
	if not entity then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:123')
		return
	end
	if not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:126')
		return
	end
	if not entity.unit_number then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:129')
		return
	end
	local wagon = icw.wagons[entity.unit_number]
	if not wagon then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:133')
		return
	end
	Functions.draw_minimap(icw, game.players[event.player_index], wagon.surface, {
		wagon.area.left_top.x + (wagon.area.right_bottom.x - wagon.area.left_top.x) * 0.5,
		wagon.area.left_top.y + (wagon.area.right_bottom.y - wagon.area.left_top.y) * 0.5,
	})
end

local function on_player_died(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:141')
	Functions.kill_minimap(game.players[event.player_index])
end

local function on_train_created(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:145')
	Functions.request_reconstruction(icw)
end

local function on_gui_click(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:149')
	Functions.toggle_minimap(icw, event)
end

local function on_tick()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:153')
	local tick = game.tick
	if tick % 60 == 0 then
		Functions.item_transfer(icw)
	end
	if tick % 240 == 0 then
		Functions.update_minimap(icw)
	end

	if not icw.rebuild_tick then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:163')
		return
	end
	if icw.rebuild_tick ~= tick then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:166')
		return
	end
	Functions.reconstruct_all_trains(icw)
	icw.rebuild_tick = nil
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:172')
	Public.reset()
end

function Public.get_table()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:176')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:177')
	return icw
end

--Set delay_surface to true when using on_chunk_generated event, to prevent issues.
function Public.register_wagon(wagon_entity, delay_surface)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:181')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:182')
	return Functions.create_wagon(icw, wagon_entity, delay_surface)
end

Event.on_init(on_init)
Event.add(defines.events.on_built_entity, on_built_entity)
Event.add(defines.events.on_entity_died, on_entity_died)
Event.add(defines.events.on_gui_click, on_gui_click)
Event.add(defines.events.on_gui_closed, on_gui_closed)
Event.add(defines.events.on_gui_opened, on_gui_opened)
Event.add(defines.events.on_player_died, on_player_died)
Event.add(defines.events.on_player_driving_changed_state, on_player_driving_changed_state)
Event.add(defines.events.on_player_joined_game, on_player_joined_game)
Event.add(defines.events.on_player_left_game, on_player_left_game)
Event.add(defines.events.on_player_mined_entity, on_player_mined_entity)
Event.add(defines.events.on_robot_built_entity, on_robot_built_entity)
Event.add(defines.events.on_robot_mined_entity, on_robot_mined_entity)
Event.add(defines.events.on_tick, on_tick)
Event.add(defines.events.on_train_created, on_train_created)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/immersive_cargo_wagons/main.lua:201')
return Public
