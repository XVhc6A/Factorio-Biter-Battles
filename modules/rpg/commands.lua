local RPG = require("modules.rpg.table")
local Utils = require("utils.core")
local Color = require("utils.color_presets")

local round = math.round

local validate_args = function(data)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:6')
	local player = data.player
	local target = data.target
	local rpg_t = data.rpg_t

	if not target then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:12')
		return false
	end

	if not target.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:16')
		return false
	end

	if not target.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:20')
		return false
	end

	if not target.connected then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:24')
		return false
	end

	if not game.players[target.index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:28')
		return false
	end

	if not player then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:32')
		return false
	end

	if not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:36')
		return false
	end

	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:40')
		return false
	end

	if not player.connected then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:44')
		return false
	end

	if not game.players[player.index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:48')
		return false
	end

	if not target or not game.players[target.index] then
		Utils.print_to(player, "Invalid name.")
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:53')
		return false
	end

	if not rpg_t[target.index] then
		Utils.print_to(player, "Invalid target.")
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:58')
		return false
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:61')
	return true
end

local print_stats = function(target, tbl)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:64')
	if not target then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:66')
		return
	end
	if not tbl then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:69')
		return
	end
	local t = tbl[target.index]
	local level = t.level
	local xp = round(t.xp)
	local strength = t.strength
	local magicka = t.magicka
	local dexterity = t.dexterity
	local vitality = t.vitality
	local output = "[color=blue]" .. target.name .. "[/color] has the following stats: \n"
	output = output .. "[color=green]Level:[/color] " .. level .. "\n"
	output = output .. "[color=green]XP:[/color] " .. xp .. "\n"
	output = output .. "[color=green]Strength:[/color] " .. strength .. "\n"
	output = output .. "[color=green]Magic:[/color] " .. magicka .. "\n"
	output = output .. "[color=green]Dexterity:[/color] " .. dexterity .. "\n"
	output = output .. "[color=green]Vitality:[/color] " .. vitality

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:86')
	return output
end

commands.add_command("stats", "Check what stats a user has!", function(cmd)
	local player = game.player

	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:93')
		return
	end

	local param = cmd.parameter
	if not param then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:98')
		return
	end

	if param == "" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:102')
		return
	end

	local target = game.players[param]
	if not target or not target.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/commands.lua:107')
		return
	end

	local rpg_t = RPG.get("rpg_t")

	local data = {
		player = player,
		target = target,
		rpg_t = rpg_t,
	}

	if validate_args(data) then
		local msg = print_stats(target, rpg_t)
		player.play_sound({ path = "utility/scenario_message", volume_modifier = 1 })
		player.print(msg)
	else
		player.print("Please type a name of a player who is connected.", Color.warning)
	end
end)
