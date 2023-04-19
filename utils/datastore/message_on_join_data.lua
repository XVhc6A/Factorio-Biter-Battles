local Token = require("utils.token")
local Color = require("utils.color_presets")
local Server = require("utils.server")
local Event = require("utils.event")

local message_dataset = "regulars"
local set_data = Server.set_data
local try_get_data = Server.try_get_data

local Public = {}

local fetch = Token.register(function(data)
	local key = data.key
	local value = data.value
	local player = game.players[key]
	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/message_on_join_data.lua:16')
		return
	end
	if type(value) == "table" then
		game.print(">> " .. player.name .. " << " .. value.msg, value.color)
	end
end)

--- Tries to get data from the webpanel and applies the value to the player.
-- @param data_set player token
function Public.fetch(key)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/message_on_join_data.lua:25')
	local secs = Server.get_current_time()
	if not secs then
		local player = game.players[key]
		if not player or not player.valid then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/message_on_join_data.lua:30')
			return
		end
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/message_on_join_data.lua:32')
		return
	else
		try_get_data(message_dataset, key, fetch)
	end
end

commands.add_command("save-message", "Sets your custom join message.", function(cmd)
	local player = game.player
	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/message_on_join_data.lua:41')
		return
	end

	local secs = Server.get_current_time()
	if not secs then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/message_on_join_data.lua:46')
		return
	end

	local param = cmd.parameter
	if param then
		if param == "" or param == "Name" then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/message_on_join_data.lua:52')
			return player.print("You did not specify a message.", Color.warning)
		end
		if string.len(param) > 64 then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/message_on_join_data.lua:55')
			return player.print("Message is too long. 64 characters maximum.", { r = 0.90, g = 0.0, b = 0.0 })
		end
		set_data(message_dataset, player.name, { msg = param, color = player.color })
		player.print("You message has been saved.", Color.success)
	else
		player.print("You did not specify a message.", Color.warning)
	end
end)

commands.add_command("remove-message", "Removes your custom join message.", function()
	local player = game.player
	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/message_on_join_data.lua:67')
		return
	end

	set_data(message_dataset, player.name, nil)
	player.print("Your message has been removed.", Color.success)
end)

Event.add(defines.events.on_player_joined_game, function(event)
	local player = game.get_player(event.player_index)
	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/message_on_join_data.lua:77')
		return
	end

	Public.fetch(player.name)
end)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/message_on_join_data.lua:83')
return Public
