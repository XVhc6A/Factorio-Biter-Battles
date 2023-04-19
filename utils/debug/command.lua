local DebugView = require("utils.debug.main_view")

commands.add_command("debug", "Opens the debugger", function(_)
	local player = game.player
	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/command.lua:5')
		return
	end

	if not player.admin then
		player.print("Only admins can use this command.")
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/command.lua:10')
		return
	end
	DebugView.open_debug(player)
end)

if _DEBUG then
	local Model = require("model")

	local loadstring = loadstring
	local pcall = pcall
	local dump = Model.dump
	local log = log

	commands.add_command("dump-log", "Dumps value to log", function(args)
		local player = game.player
		local p
		if player then
			p = player.print
			if not player.admin then
				p("Only admins can use this command.")
				log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/command.lua:30')
				return
			end
		else
			p = player.print
		end
		if args.parameter == nil then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/command.lua:36')
			return
		end
		local func, err = loadstring("return " .. args.parameter)

		if not func then
			p(err)
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/command.lua:42')
			return
		end

		local suc, value = pcall(func)

		if not suc then
			p(value)
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/command.lua:49')
			return
		end

		log(dump(value))
	end)

	commands.add_command("dump-file", "Dumps value to dump.lua", function(args)
		local player = game.player
		local p
		if player then
			p = player.print
			if not player.admin then
				p("Only admins can use this command.")
				log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/command.lua:62')
				return
			end
		else
			p = player.print
		end
		if args.parameter == nil then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/command.lua:68')
			return
		end
		local func, err = loadstring("return " .. args.parameter)

		if not func then
			p(err)
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/command.lua:74')
			return
		end

		local suc, value = pcall(func)

		if not suc then
			p(value)
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/command.lua:81')
			return
		end

		value = dump(value)
		game.write_file("dump.lua", value, false)
	end)
end
