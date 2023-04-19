local Global = require("utils.global")
local Event = require("utils.event")

local offline_characters = {}
Global.register(offline_characters, function(tbl)
	offline_characters = tbl
end)

local function on_player_joined_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/offline_characters.lua:8')
	local player = game.players[event.player_index]
	if not offline_characters[player.index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/offline_characters.lua:11')
		return
	end

	local offline_character = offline_characters[player.index]
	if not offline_character or not offline_character.valid then
		offline_characters[player.index] = nil
		if not player.character or player.character.valid then
			player.set_controller({ type = defines.controllers.god })
			player.create_character()
		end
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/offline_characters.lua:21')
		return
	end

	local c = player.character
	if c and c.valid then
		player.character = nil
		c.destroy()
	end

	player.associate_character(offline_character)
	player.set_controller({ type = defines.controllers.character, character = offline_character })
	offline_characters[player.index] = nil
end

local function on_pre_player_left_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/offline_characters.lua:35')
	local player = game.players[event.player_index]
	local character = player.character
	if not character or not character.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/offline_characters.lua:39')
		return
	end
	player.set_controller({ type = defines.controllers.god })
	character.driving = false
	character.associated_player = nil
	character.color = { 125, 125, 125 }
	offline_characters[player.index] = character
end

Event.add(defines.events.on_player_joined_game, on_player_joined_game)
Event.add(defines.events.on_pre_player_left_game, on_pre_player_left_game)
