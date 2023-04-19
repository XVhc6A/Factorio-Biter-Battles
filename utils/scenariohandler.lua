local Color = require("utils.color_presets")
local Server = require("utils.server")
local Global = require("utils.globals")

local mapkeeper = "[color=blue]Mapkeeper:[/color]"

local Public = {}

local this = {
	scenarioname = "",
	reset_are_you_sure = false,
	restart = false,
	soft_reset = false,
	shutdown = false,
	accepted_params = {
		["restart"] = true,
		["resetnow"] = true,
		["shutdown"] = true,
		["restartnow"] = true,
	},
}

Global.register(this, function(t)
	this = t
end)

commands.add_command("scenario", "Usable only for admins - controls the scenario!", function(cmd)
	local p
	local player = game.player

	if not player or not player.valid then
		p = log
	else
		p = player.print
		if not player.admin then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:35')
			return
		end
	end

	local param = cmd.parameter

	if this.accepted_params[param] then
		goto continue
	else
		p("[ERROR] Arguments was invalid.")
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:45')
		return
	end

	::continue::

	if not this.reset_are_you_sure then
		this.reset_are_you_sure = true
		p(
			"[WARNING] This command will disable the soft-reset feature, run this command again if you really want to do this!"
		)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:55')
		return
	end

	if param == "restart" then
		if this.restart then
			this.reset_are_you_sure = nil
			this.restart = false
			this.soft_reset = true
			p("[SUCCESS] Soft-reset is once again enabled.")
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:64')
			return
		else
			this.reset_are_you_sure = nil
			this.restart = true
			this.soft_reset = false
			if this.shutdown then
				this.shutdown = false
			end
			p("[WARNING] Soft-reset is disabled! Server will restart from scenario to load new changes.")
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:73')
			return
		end
	elseif param == "restartnow" then
		this.reset_are_you_sure = nil
		p(player.name .. " restarted the game.")
		Server.start_scenario(this.scenarioname)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:79')
		return
	elseif param == "shutdown" then
		if this.shutdown then
			this.reset_are_you_sure = nil
			this.shutdown = false
			this.soft_reset = true
			p("[SUCCESS] Soft-reset is once again enabled.")
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:86')
			return
		else
			this.reset_are_you_sure = nil
			this.shutdown = true
			this.soft_reset = false
			if this.restart then
				this.restart = false
			end
			p("[WARNING] Soft-reset is disabled! Server will shutdown. Most likely because of updates.")
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:95')
			return
		end
	elseif param == "reset" then
		this.reset_are_you_sure = nil
		if player and player.valid then
			game.print(mapkeeper .. " " .. player.name .. ", has reset the game!", { r = 0.98, g = 0.66, b = 0.22 })
		else
			game.print(mapkeeper .. " server, has reset the game!", { r = 0.98, g = 0.66, b = 0.22 })
		end
		reset_map()
		p("[WARNING] Game has been reset!")
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:106')
		return
	end
end)

function Public.map_reset_callback(data, callback)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:110')
	if not data then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:112')
		return
	end
	if not callback then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:115')
		return
	end

	if not string.find(callback, "%s") and not string.find(callback, "return") then
		callback = "return " .. callback
	end

	if type(callback) == "function" then
		local success, err = pcall(callback, data)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:124')
		return success, err
	else
		local success, err = pcall(loadstring(callback), data)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:127')
		return success, err
	end
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/scenariohandler.lua:131')
return Public
