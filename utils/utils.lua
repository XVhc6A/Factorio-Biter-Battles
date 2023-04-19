local Module = {}

Module.distance = function(pos1, pos2)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:2')
	local dx = pos2.x - pos1.x
	local dy = pos2.y - pos1.y
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:5')
	return math.sqrt(dx * dx + dy * dy)
end

-- rounds number (num) to certain number of decimal places (idp)
math.round = function(num, idp)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:9')
	local mult = 10 ^ (idp or 0)
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:11')
	return math.floor(num * mult + 0.5) / mult
end

function math.clamp(num, min, max)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:14')
	if num < min then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:16')
		return min
	elseif num > max then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:18')
		return max
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:20')
		return num
	end
end

Module.print_except = function(msg, player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:24')
	for _, p in pairs(game.players) do
		if p.connected and p ~= player then
			p.print(msg)
		end
	end
end

Module.print_admins = function(msg)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:32')
	for _, p in pairs(game.players) do
		if p.connected and p.admin then
			p.print(msg)
		end
	end
end

Module.get_actor = function()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:40')
	if game.player then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:42')
		return game.player.name
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:44')
	return "<server>"
end

Module.cast_bool = function(var)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:47')
	if var then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:49')
		return true
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:51')
		return false
	end
end

Module.find_entities_by_last_user = function(player, surface, filters)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:55')
	if type(player) == "string" or not player then
		error(
			"bad argument #1 to '"
				.. debug.getinfo(1, "n").name
				.. "' (number or LuaPlayer expected, got "
				.. type(player)
				.. ")",
			1
		)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:65')
		return
	end
	if type(surface) ~= "table" and type(surface) ~= "number" then
		error(
			"bad argument #2 to '"
				.. debug.getinfo(1, "n").name
				.. "' (number or LuaSurface expected, got "
				.. type(surface)
				.. ")",
			1
		)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:76')
		return
	end
	local entities = {}
	local surface = surface
	local player = player
	local filters = filters or {}
	if type(surface) == "number" then
		surface = game.surfaces[surface]
	end
	if type(player) == "number" then
		player = game.players[player]
	end
	filters.force = player.force.name
	for _, e in pairs(surface.find_entities_filtered(filters)) do
		if e.last_user == player then
			table.insert(entities, e)
		end
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:94')
	return entities
end

Module.ternary = function(c, t, f)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:97')
	if c then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:99')
		return t
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:101')
		return f
	end
end

local minutes_to_ticks = 60 * 60
local hours_to_ticks = 60 * 60 * 60
local ticks_to_minutes = 1 / minutes_to_ticks
local ticks_to_hours = 1 / hours_to_ticks
Module.format_time = function(ticks)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:109')
	local result = {}

	local hours = math.floor(ticks * ticks_to_hours)
	if hours > 0 then
		ticks = ticks - hours * hours_to_ticks
		table.insert(result, hours)
		if hours == 1 then
			table.insert(result, "hour")
		else
			table.insert(result, "hours")
		end
	end

	local minutes = math.floor(ticks * ticks_to_minutes)
	table.insert(result, minutes)
	if minutes == 1 then
		table.insert(result, "minute")
	else
		table.insert(result, "minutes")
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:131')
	return table.concat(result, " ")
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/utils.lua:134')
return Module
