local Server = require("utils.server")
local Color = require("utils.color_presets")

local function revote()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/commands/difficulty_voting_commands.lua:3')
	local player = game.player

	if player and player ~= nil then
		if not player.admin then
			player.print("[ERROR] Command is admin-only. Please ask an admin.", Color.warning)
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/commands/difficulty_voting_commands.lua:9')
			return
		else
			local tick = game.ticks_played
			global.difficulty_votes_timeout = tick + 10800
			global.difficulty_player_votes = {}
			msg = player.name .. " opened difficulty voting. Voting enabled for 3 mins"
			game.print(msg)
			Server.to_discord_embed(msg)
		end
	end
end

local function close_difficulty_votes()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/commands/difficulty_voting_commands.lua:21')
	local player = game.player

	if player and player ~= nil then
		if not player.admin then
			player.print("[ERROR] Command is admin-only. Please ask an admin.", Color.warning)
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/commands/difficulty_voting_commands.lua:27')
			return
		else
			global.difficulty_votes_timeout = game.ticks_played
			msg = player.name .. " closed difficulty voting"
			game.print(msg)
			Server.to_discord_embed(msg)
		end
	end
end

commands.add_command("difficulty-revote", "open difficulty revote", function(cmd)
	revote()
end)

commands.add_command("difficulty-close-vote", "open difficulty revote", function(cmd)
	close_difficulty_votes()
end)
