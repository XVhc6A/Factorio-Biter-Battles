local Token = require("utils.token")
local Color = require("utils.color_presets")
local Server = require("utils.server")
local Event = require("utils.event")

local tag_dataset = "tags"
local set_data = Server.set_data
local try_get_data = Server.try_get_data

local Public = {}

local fetch = Token.register(function(data)
	local key = data.key
	local value = data.value
	local player = game.players[key]
	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:16')
		return
	end

	if type(value) == "string" then
		player.tag = "[" .. value .. "]"
	end
end)

local alphanumeric = function(str)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:24')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:25')
	return (string.match(str, "[^%w]") ~= nil)
end

--- Tries to get data from the webpanel and applies the value to the player.
-- @param data_set player token
function Public.fetch(key)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:30')
	local secs = Server.get_current_time()
	if not secs then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:33')
		return
	else
		try_get_data(tag_dataset, key, fetch)
	end
end

commands.add_command("save-tag", "Sets your custom tag that is persistent.", function(cmd)
	local player = game.player
	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:42')
		return
	end

	local secs = Server.get_current_time()
	if not secs then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:47')
		return
	end

	local param = cmd.parameter

	if param then
		if alphanumeric(param) then
			player.print("Tag is not valid.", { r = 0.90, g = 0.0, b = 0.0 })
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:55')
			return
		end

		if param == "" or param == "Name" then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:59')
			return player.print("You did not specify a tag.", Color.warning)
		end

		if string.len(param) > 32 then
			player.print("Tag is too long. 64 characters maximum.", { r = 0.90, g = 0.0, b = 0.0 })
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:64')
			return
		end

		set_data(tag_dataset, player.name, param)
		player.tag = "[" .. param .. "]"
		player.print("Your tag has been saved.", Color.success)
	else
		player.print("You did not specify a tag.", Color.warning)
	end
end)

commands.add_command("remove-tag", "Removes your custom tag.", function()
	local player = game.player
	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:78')
		return
	end

	set_data(tag_dataset, player.name, nil)
	player.print("Your tag has been removed.", Color.success)
end)

Event.add(defines.events.on_player_joined_game, function(event)
	local player = game.get_player(event.player_index)
	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:88')
		return
	end

	Public.fetch(player.name)
end)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/player_tag_data.lua:94')
return Public
