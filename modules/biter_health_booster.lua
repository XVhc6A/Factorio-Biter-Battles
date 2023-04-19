-- Biters, Spawners and Worms gain additional health / resistance -- mewmew
-- Use global.biter_health_boost or global.biter_health_boost_forces to modify their health.
-- 1 = vanilla health, 2 = 200% vanilla health
-- do not use values below 1
local math_floor = math.floor
local math_round = math.round
local Public = {}

local entity_types = {
	["unit"] = true,
	["turret"] = true,
	["unit-spawner"] = true,
}

if package.loaded["maps.biter_hatchery.terrain"] then
	entity_types["unit-spawner"] = nil
end

local function clean_table()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:18')
	--Perform a table cleanup every 1000 boosts
	global.biter_health_boost_count = global.biter_health_boost_count + 1
	if global.biter_health_boost_count % 1000 ~= 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:22')
		return
	end

	local units_to_delete = {}

	--Mark all health boost entries for deletion
	for key, health in pairs(global.biter_health_boost_units) do
		units_to_delete[key] = true
	end

	--Remove valid health boost entries from deletion
	local validtypes = {}
	for k, v in pairs(entity_types) do
		if v then
			table.insert(validtypes, k)
		end
	end
	for _, surface in pairs(game.surfaces) do
		for _, unit in pairs(surface.find_entities_filtered({ type = validtypes })) do
			units_to_delete[unit.unit_number] = nil
		end
	end

	--Remove abandoned health boost entries
	for key, _ in pairs(units_to_delete) do
		global.biter_health_boost_units[key] = nil
	end
end

local function create_boss_healthbar(entity, size)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:51')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:52')
	return rendering.draw_sprite({
		sprite = "virtual-signal/signal-white",
		tint = { 0, 200, 0 },
		x_scale = size * 15,
		y_scale = size,
		render_layer = "light-effect",
		target = entity,
		target_offset = { 0, -2.5 },
		surface = entity.surface,
	})
end

local function set_boss_healthbar(health, max_health, healthbar_id)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:64')
	local m = health / max_health
	local x_scale = rendering.get_y_scale(healthbar_id) * 15
	rendering.set_x_scale(healthbar_id, x_scale * m)
	rendering.set_color(healthbar_id, { math_floor(255 - 255 * m), math_floor(200 * m), 0 })
end

function Public.add_unit(unit, health_multiplier)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:71')
	if not health_multiplier then
		health_multiplier = global.biter_health_boost
	end
	global.biter_health_boost_units[unit.unit_number] = {
		math_floor(unit.prototype.max_health * health_multiplier),
		math_round(1 / health_multiplier, 5),
	}
	clean_table()
end

function Public.add_boss_unit(unit, health_multiplier, health_bar_size)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:82')
	if not health_multiplier then
		health_multiplier = global.biter_health_boost
	end
	if not health_bar_size then
		health_bar_size = 0.5
	end
	local health = math_floor(unit.prototype.max_health * health_multiplier)
	global.biter_health_boost_units[unit.unit_number] = {
		health,
		math_round(1 / health_multiplier, 5),
		{ max_health = health, healthbar_id = create_boss_healthbar(unit, health_bar_size), last_update = game.tick },
	}
	clean_table()
end

local function on_entity_damaged(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:98')
	local biter = event.entity
	if not (biter and biter.valid) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:101')
		return
	end
	if not entity_types[biter.type] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:104')
		return
	end

	local biter_health_boost_units = global.biter_health_boost_units

	local unit_number = biter.unit_number

	--Create new health pool
	local health_pool = biter_health_boost_units[unit_number]
	if not health_pool then
		if global.biter_health_boost_forces[biter.force.index] then
			Public.add_unit(biter, global.biter_health_boost_forces[biter.force.index])
		else
			Public.add_unit(biter, global.biter_health_boost)
		end
		health_pool = global.biter_health_boost_units[unit_number]
	end

	--Process boss unit health bars
	local boss = health_pool[3]
	if boss then
		if boss.last_update + 10 < game.tick then
			set_boss_healthbar(health_pool[1], boss.max_health, boss.healthbar_id)
			boss.last_update = game.tick
		end
	end

	--Reduce health pool
	health_pool[1] = health_pool[1] - event.final_damage_amount

	--Set entity health relative to health pool
	biter.health = health_pool[1] * health_pool[2]

	--Proceed to kill entity if health is 0
	if biter.health > 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:139')
		return
	end

	if event.cause then
		if event.cause.valid then
			event.entity.die(event.cause.force, event.cause)
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:145')
			return
		end
	end
	biter.die(biter.force)
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:151')
	global.biter_health_boost = 1
	global.biter_health_boost_forces = {}
	global.biter_health_boost_units = {}
	global.biter_health_boost_count = 0
end

local event = require("utils.event")
event.on_init(on_init)
event.add(defines.events.on_entity_damaged, on_entity_damaged)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_health_booster.lua:162')
return Public
