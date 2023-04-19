local Global = require("utils.global")
local Event = require("utils.event")

local this = {
	fullness_enabled = true,
	warned = {},
}

Global.register(this, function(t)
	this = t
end)

local Public = {}
local random = math.random
local ceil = math.ceil

local function is_player_warned(player, reset)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:16')
	if reset and this.warned[player.index] then
		this.warned[player.index] = nil
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:19')
		return
	end
	if not this.warned[player.index] then
		this.warned[player.index] = {
			count = 2,
		}
	end
	this.warned[player.index].count = this.warned[player.index].count + 1
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:27')
	return this.warned[player.index]
end

local function compute_fullness(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:30')
	local warn_player = is_player_warned(player)
	local free_slots = player.get_main_inventory().count_empty_stacks()
	if free_slots == 0 then
		if player.character then
			local damage = ceil((warn_player.count / 2) * warn_player.count)
			if player.character.health >= damage then
				player.character.damage(damage, "player", "explosion")
				player.character.surface.create_entity({ name = "water-splash", position = player.position })
				local messages = {
					"Ouch.. That hurt! Better be careful now.",
					"Just a fleshwound.",
					"Better keep those hands to yourself or you might loose them.",
				}
				player.print(messages[random(1, #messages)], { r = 0.75, g = 0.0, b = 0.0 })
			else
				player.character.die("enemy")
				is_player_warned(player, true)
				game.print(player.name .. " should have emptied their pockets.", { r = 0.75, g = 0.0, b = 0.0 })
				log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:49')
				return free_slots
			end
		end
	else
		is_player_warned(player, true)
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:55')
	return free_slots
end

function Public.check_fullness(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:58')
	if this.fullness_enabled then
		local fullness = compute_fullness(player)
		if fullness == 0 then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:62')
			return
		end
	end
end

function Public.enable_fullness(value)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:67')
	if value then
		this.fullness_enabled = value
	else
		this.fullness_enabled = false
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:73')
	return this.fullness_enabled
end

function Public.get(key)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:76')
	if key then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:78')
		return this[key]
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:80')
		return this
	end
end

local check_fullness = Public.check_fullness

Event.add(defines.events.on_player_mined_entity, function(event)
	local entity = event.entity
	if not entity or not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:89')
		return
	end

	local player = game.players[event.player_index]
	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:94')
		return
	end

	if not this.fullness_enabled then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:98')
		return
	end

	check_fullness(player)
end)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/check_fullness.lua:104')
return Public
