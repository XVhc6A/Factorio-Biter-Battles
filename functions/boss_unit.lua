--adds a health bar and health increase to a unit

local function create_healthbar(entity, size)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:2')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:3')
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

local function set_healthbar(boss_unit)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:15')
	local m = boss_unit.health / boss_unit.max_health
	local x_scale = rendering.get_y_scale(boss_unit.healthbar_id) * 15
	rendering.set_x_scale(boss_unit.healthbar_id, x_scale * m)
	rendering.set_color(boss_unit.healthbar_id, { math.floor(255 - 255 * m), math.floor(200 * m), 0 })
end

function add_boss_unit(entity, health_factor, size)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:22')
	if not entity then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:24')
		return
	end
	if not entity.unit_number then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:27')
		return
	end
	if not health_factor then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:30')
		return
	end
	local health = math.floor(entity.prototype.max_health * health_factor)
	if health == 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:34')
		return
	end
	local s = 0.5
	if size then
		s = size
	end
	global.boss_units[entity.unit_number] = {
		entity = entity,
		max_health = health,
		health = health,
		healthbar_id = create_healthbar(entity, s),
		last_update = game.tick,
	}
end

local function on_entity_damaged(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:49')
	local entity = event.entity
	if not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:52')
		return
	end
	if entity.type ~= "unit" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:55')
		return
	end
	local boss = global.boss_units[entity.unit_number]
	if not boss then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:59')
		return
	end
	entity.health = entity.health + event.final_damage_amount
	boss.health = boss.health - event.final_damage_amount
	if boss.health <= 0 then
		global.boss_units[entity.unit_number] = nil
		entity.die()
	else
		if boss.last_update + 10 < game.tick then
			set_healthbar(global.boss_units[entity.unit_number])
			boss.last_update = game.tick
		end
	end
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/boss_unit.lua:74')
	global.boss_units = {}
end

local event = require("utils.event")
event.on_init(on_init)
event.add(defines.events.on_entity_damaged, on_entity_damaged)
