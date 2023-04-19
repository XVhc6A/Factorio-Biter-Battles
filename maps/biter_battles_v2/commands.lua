local Server = require("utils.server")
local mapkeeper = "[color=blue]Mapkeeper:[/color]"

commands.add_command("scenario", "Usable only for admins - controls the scenario!", function(cmd)
	local p
	local player = game.player

	if not player or not player.valid then
		p = log
	else
		p = player.print
		if not player.admin then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/commands.lua:12')
			return
		end
	end

	local param = cmd.parameter

	if param == "restart" or param == "shutdown" or param == "restartnow" then
		goto continue
	else
		p("[ERROR] Arguments are:\nrestart\nshutdown\nrestartnow")
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/commands.lua:22')
		return
	end

	::continue::

	if not global.reset_are_you_sure then
		global.reset_are_you_sure = true
		p(
			"[WARNING] This command will disable the soft-reset feature, run this command again if you really want to do this!"
		)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/commands.lua:32')
		return
	end

	if param == "restart" then
		if global.restart then
			global.reset_are_you_sure = nil
			global.restart = false
			global.soft_reset = true
			p("[SUCCESS] Soft-reset is enabled.")
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/commands.lua:41')
			return
		else
			global.reset_are_you_sure = nil
			global.restart = true
			global.soft_reset = false
			if global.shutdown then
				global.shutdown = false
			end
			p("[WARNING] Soft-reset is disabled! Server will restart from scenario.")
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/commands.lua:50')
			return
		end
	elseif param == "restartnow" then
		global.reset_are_you_sure = nil
		p(player.name .. " has restarted the game.")
		Server.start_scenario("Biter_Battles")
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/commands.lua:56')
		return
	elseif param == "shutdown" then
		if global.shutdown then
			global.reset_are_you_sure = nil
			global.shutdown = false
			global.soft_reset = true
			p("[SUCCESS] Soft-reset is enabled.")
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/commands.lua:63')
			return
		else
			global.reset_are_you_sure = nil
			global.shutdown = true
			global.soft_reset = false
			if global.restart then
				global.restart = false
			end
			p("[WARNING] Soft-reset is disabled! Server will shutdown.")
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/commands.lua:72')
			return
		end
	end
end)
