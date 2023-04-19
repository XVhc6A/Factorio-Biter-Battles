-- Biter Battles v2 -- by MewMew

local Ai = require("maps.biter_battles_v2.ai")
local Functions = require("maps.biter_battles_v2.functions")
local Game_over = require("maps.biter_battles_v2.game_over")
local Gui = require("maps.biter_battles_v2.gui")
local Init = require("maps.biter_battles_v2.init")
local Mirror_terrain = require("maps.biter_battles_v2.mirror_terrain")
require("modules.simple_tags")
local Team_manager = require("maps.biter_battles_v2.team_manager")
local Terrain = require("maps.biter_battles_v2.terrain")
local Session = require("utils.datastore.session_data")
local Color = require("utils.color_presets")
local autoTagWestOutpost = "[West]"
local autoTagEastOutpost = "[East]"
local autoTagDistance = 600

require("maps.biter_battles_v2.sciencelogs_tab")
require("maps.biter_battles_v2.changelog_tab")
require("maps.biter_battles_v2.commands")
require("modules.spawners_contain_biters")

local function on_player_joined_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:22')
	local surface = game.surfaces[global.bb_surface_name]
	local player = game.players[event.player_index]
	if player.online_time == 0 or player.force.name == "player" then
		Functions.init_player(player)
	end
	Gui.clear_copy_history(player)
	Functions.create_map_intro_button(player)
	Team_manager.draw_top_toggle_button(player)
end

local function on_gui_click(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:33')
	local player = game.players[event.player_index]
	local element = event.element
	if not element then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:37')
		return
	end
	if not element.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:40')
		return
	end

	if Functions.map_intro_click(player, element) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:44')
		return
	end
	Team_manager.gui_click(event)
end

local function on_research_finished(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:49')
	Functions.combat_balance(event)
end

local function on_console_chat(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:53')
	Functions.share_chat(event)
end

local function on_built_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:57')
	Functions.no_landfill_by_untrusted_user(event)
	Functions.no_turret_creep(event)
	Terrain.deny_enemy_side_ghosts(event)
	Functions.add_target_entity(event.created_entity)
end

local function on_robot_built_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:64')
	Functions.no_turret_creep(event)
	Terrain.deny_construction_bots(event)
	Functions.add_target_entity(event.created_entity)
end

local function on_robot_built_tile(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:70')
	Terrain.deny_bot_landfill(event)
end

local function on_entity_died(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:74')
	local entity = event.entity
	if not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:77')
		return
	end
	if Ai.subtract_threat(entity) then
		Gui.refresh_threat()
	end
	if Functions.biters_landfill(entity) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:83')
		return
	end
	Game_over.silo_death(event)
end

local function getTagOutpostName(pos)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:88')
	if pos < 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:90')
		return autoTagWestOutpost
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:92')
		return autoTagEastOutpost
	end
end

local function hasOutpostTag(tagName)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:96')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:97')
	return (string.find(tagName, "%" .. autoTagWestOutpost) or string.find(tagName, "%" .. autoTagEastOutpost))
end

local function autotagging_outposters()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:100')
	for _, p in pairs(game.connected_players) do
		if p.force.name == "north" or p.force.name == "south" then
			if math.abs(p.position.x) < autoTagDistance then
				if hasOutpostTag(p.tag) then
					p.tag = p.tag:gsub("%" .. autoTagWestOutpost, "")
					p.tag = p.tag:gsub("%" .. autoTagEastOutpost, "")
				end
			else
				if not hasOutpostTag(p.tag) then
					p.tag = p.tag .. getTagOutpostName(p.position.x)
				end
			end
		end

		if p.force.name == "spectator" and hasOutpostTag(p.tag) then
			p.tag = p.tag:gsub("%" .. autoTagWestOutpost, "")
			p.tag = p.tag:gsub("%" .. autoTagEastOutpost, "")
		end
	end
end

local tick_minute_functions = {
	[300 * 1] = Ai.raise_evo,
	[300 * 3 + 30 * 0] = Ai.pre_main_attack, -- setup for main_attack
	[300 * 3 + 30 * 1] = Ai.perform_main_attack, -- call perform_main_attack 7 times on different ticks
	[300 * 3 + 30 * 2] = Ai.perform_main_attack, -- some of these might do nothing (if there are no wave left)
	[300 * 3 + 30 * 3] = Ai.perform_main_attack,
	[300 * 3 + 30 * 4] = Ai.perform_main_attack,
	[300 * 3 + 30 * 5] = Ai.perform_main_attack,
	[300 * 3 + 30 * 6] = Ai.perform_main_attack,
	[300 * 3 + 30 * 7] = Ai.perform_main_attack,
	[300 * 3 + 30 * 8] = Ai.post_main_attack,
	[300 * 3 + 30 * 9] = autotagging_outposters,
	[300 * 4] = Ai.send_near_biters_to_silo,
}

local function on_tick()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:137')
	local tick = game.tick

	Ai.reanimate_units()

	if tick % 60 == 0 then
		global.bb_threat["north_biters"] = global.bb_threat["north_biters"] + global.bb_threat_income["north_biters"]
		global.bb_threat["south_biters"] = global.bb_threat["south_biters"] + global.bb_threat_income["south_biters"]
	end

	if (tick + 5) % 180 == 0 then
		Gui.refresh()
	end

	if (tick + 11) % 300 == 0 then
		Gui.spy_fish()

		if global.bb_game_won_by_team then
			Game_over.reveal_map()
			Game_over.server_restart()
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:157')
			return
		end
	end

	if tick % 30 == 0 then
		local key = tick % 3600
		if tick_minute_functions[key] then
			tick_minute_functions[key]()
		end
	end
end

local function on_marked_for_deconstruction(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:169')
	if not event.entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:171')
		return
	end
	if event.entity.name == "fish" then
		event.entity.cancel_deconstruction(game.players[event.player_index].force.name)
	end
end

local function on_player_built_tile(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:178')
	local player = game.players[event.player_index]
	if event.item ~= nil and event.item.name == "landfill" then
		Terrain.restrict_landfill(player.surface, player, event.tiles)
	end
end

local function on_player_mined_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:185')
	Terrain.minable_wrecks(event)
end

local function on_chunk_generated(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:189')
	local surface = event.surface

	-- Check if we're out of init.
	if not surface or not surface.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:194')
		return
	end

	-- Necessary check to ignore nauvis surface.
	if surface.name ~= global.bb_surface_name then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:199')
		return
	end

	-- Generate structures for north only.
	local pos = event.area.left_top
	if pos.y < 0 then
		Terrain.generate(event)
	end

	-- Request chunk for opposite side, maintain the lockstep.
	-- NOTE: There is still a window where user can place down a structure
	-- and it will be mirrored. However this window is so tiny - user would
	-- need to fly in god mode and spam entities in partially generated
	-- chunks.
	local req_pos = { pos.x + 16, -pos.y + 16 }
	surface.request_to_generate_chunks(req_pos, 0)

	-- Clone from north and south. NOTE: This WILL fire 2 times
	-- for each chunk due to asynchronus nature of this event.
	-- Both sides contain arbitary amount of chunks, some positions
	-- when inverted will be still in process of generation or not
	-- generated at all. It is important to perform 2 passes to make
	-- sure everything is cloned properly. Normally we would use mutex
	-- but this is not reliable in this environment.
	Mirror_terrain.clone(event)
end

local function on_entity_cloned(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:226')
	local source = event.source
	local destination = event.destination

	-- In case entity dies between clone and this event we
	-- have to ensure south doesn't get additional objects.
	if not source.valid then
		if destination.valid then
			destination.destroy()
		end

		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:237')
		return
	end

	Mirror_terrain.invert_entity(event)
end

local function on_area_cloned(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:243')
	local surface = event.destination_surface

	-- Check if we're out of init and not between surface hot-swap.
	if not surface or not surface.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:248')
		return
	end

	-- Event is fired only for south side.
	Mirror_terrain.invert_tiles(event)
	Mirror_terrain.invert_decoratives(event)

	-- Check chunks around southen silo to remove water tiles under stone-path.
	-- Silo can be removed by picking bricks from under it in a situation where
	-- stone-path tiles were placed directly onto water tiles. This scenario does
	-- not appear for north as water is removed during silo generation.
	local position = event.destination_area.left_top
	if position.y == 64 and math.abs(position.x) <= 64 then
		Mirror_terrain.remove_hidden_tiles(event)
	end
end

local function on_rocket_launch_ordered(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:265')
	local vehicles = {
		["car"] = true,
		["tank"] = true,
		["locomotive"] = true,
		["cargo-wagon"] = true,
		["fluid-wagon"] = true,
		["spidertron"] = true,
	}
	local inventory = event.rocket.get_inventory(defines.inventory.fuel)
	local contents = inventory.get_contents()
	for name, _ in pairs(contents) do
		if vehicles[name] then
			inventory.clear()
		end
	end
end

local function clear_corpses(cmd)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:283')
	local player = game.player
	local trusted = Session.get_trusted_table()
	local param = tonumber(cmd.parameter)

	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:289')
		return
	end
	if param == nil then
		player.print("[ERROR] Must specify radius!", Color.fail)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:293')
		return
	end
	if not trusted[player.name] and not player.admin and param > 100 then
		player.print("[ERROR] Value is too big. Max radius is 100", Color.fail)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:297')
		return
	end
	if param < 0 then
		player.print("[ERROR] Value is too low.", Color.fail)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:301')
		return
	end
	if param > 500 then
		player.print("[ERROR] Value is too big.", Color.fail)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:305')
		return
	end

	if not Ai.empty_reanim_scheduler() then
		player.print("[ERROR] Some corpses are waiting to be reanimated...")
		player.print(" => Try again in short moment")
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:311')
		return
	end

	local pos = player.position

	local radius = { { x = (pos.x + -param), y = (pos.y + -param) }, { x = (pos.x + param), y = (pos.y + param) } }
	for _, entity in pairs(player.surface.find_entities_filtered({ area = radius, type = "corpse" })) do
		if entity.corpse_expires then
			entity.destroy()
		end
	end
	player.print("Cleared biter-corpses.", Color.success)
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/main.lua:325')
	Init.tables()
	Init.initial_setup()
	Init.playground_surface()
	Init.forces()
	Init.draw_structures()
	Init.load_spawn()
end

local Event = require("utils.event")
Event.add(defines.events.on_rocket_launch_ordered, on_rocket_launch_ordered)
Event.add(defines.events.on_area_cloned, on_area_cloned)
Event.add(defines.events.on_research_finished, Ai.unlock_satellite) --free silo space tech
Event.add(defines.events.on_post_entity_died, Ai.schedule_reanimate)
Event.add_event_filter(defines.events.on_post_entity_died, {
	filter = "type",
	type = "unit",
})
Event.add(defines.events.on_entity_cloned, on_entity_cloned)
Event.add(defines.events.on_built_entity, on_built_entity)
Event.add(defines.events.on_chunk_generated, on_chunk_generated)
Event.add(defines.events.on_console_chat, on_console_chat)
Event.add(defines.events.on_entity_died, on_entity_died)
Event.add(defines.events.on_gui_click, on_gui_click)
Event.add(defines.events.on_marked_for_deconstruction, on_marked_for_deconstruction)
Event.add(defines.events.on_player_built_tile, on_player_built_tile)
Event.add(defines.events.on_player_joined_game, on_player_joined_game)
Event.add(defines.events.on_player_mined_entity, on_player_mined_entity)
Event.add(defines.events.on_research_finished, on_research_finished)
Event.add(defines.events.on_robot_built_entity, on_robot_built_entity)
Event.add(defines.events.on_robot_built_tile, on_robot_built_tile)
Event.add(defines.events.on_tick, on_tick)
Event.on_init(on_init)

commands.add_command("clear-corpses", "Clears all the biter corpses..", clear_corpses)

require("maps.biter_battles_v2.spec_spy")
