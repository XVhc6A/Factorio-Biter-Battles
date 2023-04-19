--[[
FJEI - "Factorio Just enough items"
A comfy recipe browser - MewMew
]]

local Gui = require("modules.fjei.gui")
local Functions = require("modules.fjei.functions")
local recipe_window_position = "center"

local function on_player_joined_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:9')
	local player = game.players[event.player_index]

	if not global.fjei then
		Public.build_tables()
	end
	if not global.fjei.player_data[player.index] then
		global.fjei.player_data[player.index] = {}
	end

	Gui.draw_top_toggle_button(player)
	Gui.refresh_main_window(player)
end

local function on_player_left_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:23')
	local player = game.players[event.player_index]
	global.fjei.player_data[player.index].history = nil
	global.fjei.player_data[player.index].filtered_list = nil
	global.fjei.player_data[player.index] = nil
end

local function on_research_finished(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:30')
	if not Functions.add_research_to_whitelist(event.research.force, event.research.effects) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:32')
		return
	end
	local player_data = global.fjei.player_data
	for _, player in pairs(event.research.force.connected_players) do
		player_data[player.index].filtered_list = nil
		Gui.refresh_main_window(player)
	end
end

local sprite_parent_whitelist = {
	["fjei_main_window_item_list_table"] = true,
	["fjei_main_window_history_table"] = true,
	["fjei_recipe_window"] = true,
	["fjei_recipe_window_select_table"] = true,
}

local function on_gui_click(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:48')
	local element = event.element
	if not element then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:51')
		return
	end
	if not element.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:54')
		return
	end
	local player = game.players[event.player_index]
	if Gui.gui_click_actions(element, player, event.button) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:58')
		return
	end

	if element.type ~= "sprite" and element.type ~= "choose-elem-button" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:62')
		return
	end
	local parent = element.parent
	for _ = 1, 4, 1 do
		if not parent then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:67')
			return
		end
		if not parent.name then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:70')
			return
		end
		if sprite_parent_whitelist[parent.name] then
			Gui.open_recipe(element, player, event.button)
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:74')
			return
		end
		parent = parent.parent
	end
end

local function on_gui_text_changed(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:80')
	local element = event.element
	if not element then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:83')
		return
	end
	if not element.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:86')
		return
	end
	if element.name ~= "fjei_main_window_search_textfield" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:89')
		return
	end
	local player = game.players[event.player_index]
	if element.text == "" then
		global.fjei.player_data[player.index].active_filter = false
	else
		global.fjei.player_data[player.index].active_filter = element.text
	end
	Functions.set_filtered_list(player)
	Gui.refresh_main_window(player)
end

local function on_configuration_changed()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:101')
	Functions.build_tables()
	for _, player in pairs(game.players) do
		if player.gui.left["fjei_main_window"] then
			player.gui.left["fjei_main_window"].destroy()
		end
		if player.gui[recipe_window_position]["fjei_recipe_window"] then
			player.gui[recipe_window_position]["fjei_recipe_window"].destroy()
		end
	end
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:113')
	Functions.build_tables()
end

local function on_load()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fjei/main.lua:117')
	for _, player in pairs(game.players) do
		Gui.draw_top_toggle_button(player)
	end
end

local event = require("utils.event")
event.add(defines.events.on_player_joined_game, on_player_joined_game)
event.add(defines.events.on_player_left_game, on_player_left_game)
event.add(defines.events.on_research_finished, on_research_finished)
event.add(defines.events.on_gui_click, on_gui_click)
event.add(defines.events.on_gui_text_changed, on_gui_text_changed)
script.on_configuration_changed(on_configuration_changed)
event.on_init(on_init)
event.on_init(on_load)
