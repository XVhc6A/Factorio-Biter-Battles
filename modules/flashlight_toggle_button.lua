-- toggle your flashlight -- by mewmew

local event = require("utils.event")
local message_color = { r = 200, g = 200, b = 0 }

local function on_gui_click(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/flashlight_toggle_button.lua:5')
	if not event.element then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/flashlight_toggle_button.lua:7')
		return
	end
	if not event.element.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/flashlight_toggle_button.lua:10')
		return
	end
	if not event.element.name then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/flashlight_toggle_button.lua:13')
		return
	end
	if event.element.name ~= "flashlight_toggle" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/flashlight_toggle_button.lua:16')
		return
	end
	local player = game.players[event.player_index]

	if global.flashlight_enabled[player.name] == true then
		player.character.disable_flashlight()
		player.print("Flashlight disabled.", message_color)
		global.flashlight_enabled[player.name] = false
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/flashlight_toggle_button.lua:24')
		return
	end

	if global.flashlight_enabled[player.name] == false then
		player.character.enable_flashlight()
		player.print("Flashlight enabled.", message_color)
		global.flashlight_enabled[player.name] = true
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/flashlight_toggle_button.lua:31')
		return
	end
end

local function on_player_respawned(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/flashlight_toggle_button.lua:35')
	local player = game.players[event.player_index]
	if global.flashlight_enabled[player.name] == false then
		player.character.disable_flashlight()
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/flashlight_toggle_button.lua:39')
		return
	end
	if global.flashlight_enabled[player.name] == true then
		player.character.enable_flashlight()
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/flashlight_toggle_button.lua:43')
		return
	end
end

local function on_player_joined_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/flashlight_toggle_button.lua:47')
	if not global.flashlight_enabled then
		global.flashlight_enabled = {}
	end
	local player = game.players[event.player_index]
	global.flashlight_enabled[player.name] = true
	if player.gui.top["flashlight_toggle"] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/flashlight_toggle_button.lua:54')
		return
	end
	local b = player.gui.top.add({
		type = "sprite-button",
		name = "flashlight_toggle",
		sprite = "item/small-lamp",
		tooltip = "Toggle flashlight",
	})
	b.style.minimal_height = 38
	b.style.minimal_width = 38
	b.style.top_padding = 2
	b.style.left_padding = 4
	b.style.right_padding = 4
	b.style.bottom_padding = 2
end

event.add(defines.events.on_player_joined_game, on_player_joined_game)
event.add(defines.events.on_player_respawned, on_player_respawned)
event.add(defines.events.on_gui_click, on_gui_click)
