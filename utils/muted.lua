local Global = require("utils.global")
local Color = require("utils.color_presets")
local Server = require("utils.server")
local Public = {}
local this = { muted = {} }

Global.register(this, function(t)
	this = t
end)

function Public.is_muted(player_name)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/muted.lua:10')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/muted.lua:11')
	return this.muted[player_name] == true
end

function Public.print_muted_message(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/muted.lua:14')
	player.print(
		"Did you spam pings or verbally grief? You seem to have been muted."
			.. "\nAppeal on Discord, link at biterbattles.org\nHave a break, have a KitKat.",
		Color.warning
	)
end

local function on_player_muted(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/muted.lua:22')
	if event.player_index then
		local player = game.get_player(event.player_index)
		this.muted[player.name] = true
		local message = "[MUTED] " .. player.name .. " has been muted"
		game.print(message, Color.white)
		Server.to_discord_embed(message)
	end
end

local function on_player_unmuted(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/muted.lua:32')
	if event.player_index then
		local player = game.get_player(event.player_index)
		this.muted[player.name] = nil
		local message = "[UNMUTED] " .. player.name .. " has been unmuted"
		game.print(message, Color.white)
		Server.to_discord_embed(message)
	end
end
local Event = require("utils.event")
Event.add(defines.events.on_player_muted, on_player_muted)
Event.add(defines.events.on_player_unmuted, on_player_unmuted)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/muted.lua:45')
return Public
