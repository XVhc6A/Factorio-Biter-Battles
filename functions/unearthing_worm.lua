-- by mewmew
-- modified by Gerkiz

local Event = require("utils.event")
local Global = require("utils.global")

local traps = {}

Global.register(traps, function(t)
	traps = t
end)

local function create_particles(surface, position, amount)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:12')
	if not surface.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:14')
		return
	end
	local math_random = math.random
	for i = 1, amount, 1 do
		local m = math_random(8, 24)
		local m2 = m * 0.005

		surface.create_particle({
			name = "stone-particle",
			position = position,
			frame_speed = 0.1,
			vertical_speed = 0.1,
			height = 0.1,
			movement = { m2 - (math_random(0, m) * 0.01), m2 - (math_random(0, m) * 0.01) },
		})
	end
end

local function spawn_worm(surface, position, evolution_index)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:32')
	if not surface.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:34')
		return
	end
	local worm_raffle_table = {
		[1] = {
			"small-worm-turret",
			"small-worm-turret",
			"small-worm-turret",
			"small-worm-turret",
			"small-worm-turret",
			"small-worm-turret",
		},
		[2] = {
			"small-worm-turret",
			"small-worm-turret",
			"small-worm-turret",
			"small-worm-turret",
			"small-worm-turret",
			"medium-worm-turret",
		},
		[3] = {
			"small-worm-turret",
			"small-worm-turret",
			"small-worm-turret",
			"small-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
		},
		[4] = {
			"small-worm-turret",
			"small-worm-turret",
			"small-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
		},
		[5] = {
			"small-worm-turret",
			"small-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
			"big-worm-turret",
		},
		[6] = {
			"small-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
			"big-worm-turret",
		},
		[7] = {
			"medium-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
			"big-worm-turret",
			"big-worm-turret",
		},
		[8] = {
			"medium-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
			"big-worm-turret",
			"big-worm-turret",
		},
		[9] = {
			"medium-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
			"big-worm-turret",
			"big-worm-turret",
			"big-worm-turret",
		},
		[10] = {
			"medium-worm-turret",
			"medium-worm-turret",
			"medium-worm-turret",
			"big-worm-turret",
			"big-worm-turret",
			"big-worm-turret",
		},
	}
	local raffle = worm_raffle_table[evolution_index]
	local worm_name = raffle[math.random(1, #raffle)]
	surface.create_entity({ name = worm_name, position = position })
end

local function unearthing_worm(surface, position)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:123')
	if not surface then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:125')
		return
	end
	if not surface.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:128')
		return
	end
	if not position then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:131')
		return
	end
	if not position.x then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:134')
		return
	end
	if not position.y then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:137')
		return
	end

	local evolution_index = math.ceil(game.forces.enemy.evolution_factor * 10)
	if evolution_index < 1 then
		evolution_index = 1
	end

	for t = 1, 330, 1 do
		if not traps[game.tick + t] then
			traps[game.tick + t] = {}
		end

		traps[game.tick + t][#traps[game.tick + t] + 1] = {
			callback = "create_particles",
			params = { surface, { x = position.x, y = position.y }, math.ceil(t * 0.05) },
		}

		if t == 330 then
			traps[game.tick + t][#traps[game.tick + t] + 1] = {
				callback = "spawn_worm",
				params = { surface, { x = position.x, y = position.y }, evolution_index },
			}
		end
	end
end

local function on_tick()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:164')
	if not traps[game.tick] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:166')
		return
	end
	for _, token in pairs(traps[game.tick]) do
		local callback = token.callback
		local params = token.params
		if callback == "create_particles" then
			create_particles(params[1], params[2], params[3])
		elseif callback == "spawn_worm" then
			spawn_worm(params[1], params[2], params[3])
		end
	end
	traps[game.tick] = nil
end

Event.add(defines.events.on_tick, on_tick)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/unearthing_worm.lua:182')
return unearthing_worm
