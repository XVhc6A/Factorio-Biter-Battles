local Global = require("utils.global")
local Event = require("utils.event")

local this = {
	created_items = {},
	respawn_items = {},
	skip_intro = true,
	chart_distance = 0,
	disable_crashsite = true,
	crashed_ship_items = {},
	crashed_debris_items = {},
}

Global.register(this, function(t)
	this = t
end)

local function is_game_modded()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:17')
	local i = 0
	for k, _ in pairs(game.active_mods) do
		i = i + 1
		if i > 1 then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:22')
			return true
		end
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:25')
	return false
end

local util = require("util")
local crash_site = require("crash-site")

local created_items = function()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:31')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:32')
	return {
		["iron-plate"] = 8,
		["wood"] = 1,
		["pistol"] = 1,
		["firearm-magazine"] = 10,
		["burner-mining-drill"] = 1,
		["stone-furnace"] = 1,
	}
end

local respawn_items = function()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:42')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:43')
	return {
		["pistol"] = 1,
		["firearm-magazine"] = 10,
	}
end

local ship_items = function()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:49')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:50')
	return {
		["firearm-magazine"] = 8,
	}
end

local debris_items = function()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:55')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:56')
	return {
		["iron-plate"] = 8,
	}
end

local chart_starting_area = function()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:61')
	local r = this.chart_distance or 200
	local force = game.forces.player
	local surface = game.surfaces[1]
	local origin = force.get_spawn_position(surface)
	force.chart(surface, { { origin.x - r, origin.y - r }, { origin.x + r, origin.y + r } })
end

local on_player_created = function(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:69')
	if not this.modded then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:71')
		return
	end
	local player = game.get_player(event.player_index)
	util.insert_safe(player, this.created_items)

	if not this.init_ran then
		--This is so that other mods and scripts have a chance to do remote calls before we do things like charting the starting area, creating the crash site, etc.
		this.init_ran = true

		chart_starting_area()

		if not this.disable_crashsite then
			local surface = player.surface
			surface.daytime = 0.7
			crash_site.create_crash_site(
				surface,
				{ -5, -6 },
				util.copy(this.crashed_ship_items),
				util.copy(this.crashed_debris_items)
			)
			util.remove_safe(player, this.crashed_ship_items)
			util.remove_safe(player, this.crashed_debris_items)
			player.get_main_inventory().sort_and_merge()
			if player.character then
				player.character.destructible = false
			end
			crash_site.create_cutscene(player, { -5, -4 })
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:98')
			return
		end
	end
end

local on_player_respawned = function(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:103')
	if not this.modded then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:105')
		return
	end
	local player = game.players[event.player_index]
	util.insert_safe(player, this.respawn_items)
end

local on_cutscene_waypoint_reached = function(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:111')
	if not this.modded then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:113')
		return
	end
	if not crash_site.is_crash_site_cutscene(event) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:116')
		return
	end

	local player = game.get_player(event.player_index)

	player.exit_cutscene()
end

local skip_crash_site_cutscene = function(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:124')
	if not this.modded then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:126')
		return
	end

	if event.player_index ~= 1 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:130')
		return
	end
	if event.tick > 2000 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:133')
		return
	end

	local player = game.get_player(event.player_index)
	if player.controller_type == defines.controllers.cutscene then
		player.exit_cutscene()
	end
end

local on_cutscene_cancelled = function(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:142')
	if not this.modded then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:144')
		return
	end

	local player = game.get_player(event.player_index)
	if player.gui.screen.skip_cutscene_label then
		player.gui.screen.skip_cutscene_label.destroy()
	end
	if player.character then
		player.character.destructible = true
	end
	player.zoom = 1.5
end

local freeplay_interface = {
	get_created_items = function()
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:158')
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:159')
		return this.created_items
	end,
	set_created_items = function(map)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:161')
		this.created_items = map or error("Remote call parameter to freeplay set created items can't be nil.")
	end,
	get_respawn_items = function()
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:164')
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:165')
		return this.respawn_items
	end,
	set_respawn_items = function(map)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:167')
		this.respawn_items = map or error("Remote call parameter to freeplay set respawn items can't be nil.")
	end,
	set_skip_intro = function(bool)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:170')
		this.skip_intro = bool
	end,
	set_chart_distance = function(value)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:173')
		this.chart_distance = tonumber(value)
			or error("Remote call parameter to freeplay set chart distance must be a number")
	end,
	set_disable_crashsite = function(bool)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:177')
		this.disable_crashsite = bool
	end,
	get_ship_items = function()
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:180')
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:181')
		return this.crashed_ship_items
	end,
	set_ship_items = function(map)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:183')
		this.crashed_ship_items = map or error("Remote call parameter to freeplay set created items can't be nil.")
	end,
	get_debris_items = function()
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:186')
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:187')
		return this.crashed_debris_items
	end,
	set_debris_items = function(map)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:189')
		this.crashed_debris_items = map or error("Remote call parameter to freeplay set respawn items can't be nil.")
	end,
}

if not remote.interfaces["freeplay"] then
	remote.add_interface("freeplay", freeplay_interface)
end

Event.on_init(function()
	local i = 0
	local game_has_mods = is_game_modded()
	if game_has_mods then
		this.modded = true
		this.disable_crashsite = false
		this.created_items = created_items()
		this.respawn_items = respawn_items()
		this.crashed_ship_items = ship_items()
		this.crashed_debris_items = debris_items()
	end
end)

Event.on_configuration_changed = function()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/freeplay.lua:211')
	this.created_items = this.created_items or created_items()
	this.respawn_items = this.respawn_items or respawn_items()
	this.crashed_ship_items = this.crashed_ship_items or ship_items()
	this.crashed_debris_items = this.crashed_debris_items or debris_items()

	if not this.init_ran then
		this.init_ran = #game.players > 0
	end
end

Event.add(defines.events.on_player_created, on_player_created)
Event.add(defines.events.on_player_respawned, on_player_respawned)
Event.add(defines.events.on_cutscene_waypoint_reached, on_cutscene_waypoint_reached)
Event.add("crash-site-skip-cutscene", skip_crash_site_cutscene)
Event.add(defines.events.on_cutscene_cancelled, on_cutscene_cancelled)
