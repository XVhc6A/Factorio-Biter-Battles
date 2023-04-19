--biters may revive depending of global.biter_reanimator.forces["biter force index"]
--0 = no extra life
--0.25 = 25% chance for another life
--1.5 = 1 extra life + 50% chance of another life
--3 = 3 extra lifes

local math_random = math.random

local function register_unit(unit, extra_lifes, unit_group)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_reanimator.lua:8')
	if global.biter_reanimator.units[unit.unit_number] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_reanimator.lua:10')
		return
	end
	global.biter_reanimator.units[unit.unit_number] = { extra_lifes, unit_group }
	--game.print("bitey number " .. unit.unit_number .. ", i have " .. extra_lifes .. " extra lives left!")
end

local function reanimate(entity)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_reanimator.lua:16')
	local extra_lifes = global.biter_reanimator.units[entity.unit_number][1]
	local unit_group = global.biter_reanimator.units[entity.unit_number][2]

	if extra_lifes <= 0 then
		global.biter_reanimator.units[entity.unit_number] = nil
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_reanimator.lua:22')
		return
	end

	if extra_lifes < 1 then
		if math_random(1, 10000) > extra_lifes * 10000 then
			global.biter_reanimator.units[entity.unit_number] = nil
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_reanimator.lua:28')
			return
		end
	end

	local revived_entity = entity.clone({ position = entity.position, surface = entity.surface, force = entity.force })
	revived_entity.health = revived_entity.prototype.max_health
	register_unit(revived_entity, extra_lifes - 1, unit_group)

	if unit_group then
		if unit_group.valid then
			unit_group.add_member(revived_entity)
		end
	end

	global.biter_reanimator.units[entity.unit_number] = nil
	entity.destroy()
end

local function on_entity_died(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_reanimator.lua:46')
	local entity = event.entity
	if not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_reanimator.lua:49')
		return
	end
	if entity.type ~= "unit" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_reanimator.lua:52')
		return
	end
	local extra_lifes = 0
	if global.biter_reanimator.forces[entity.force.index] then
		extra_lifes = global.biter_reanimator.forces[entity.force.index]
	end
	register_unit(entity, extra_lifes, false)
	reanimate(entity)
end

local function on_unit_added_to_group(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_reanimator.lua:62')
	local unit = event.unit
	local group = event.group
	local extra_lifes = global.biter_reanimator.forces[unit.force.index]
	if extra_lifes then
		register_unit(unit, extra_lifes, group)
	else
		register_unit(unit, 0, group)
	end
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_reanimator.lua:73')
	global.biter_reanimator = {}
	global.biter_reanimator.forces = {}
	global.biter_reanimator.units = {}
end

local Event = require("utils.event")
Event.on_init(on_init)
Event.add(defines.events.on_entity_died, on_entity_died)
Event.add(defines.events.on_unit_added_to_group, on_unit_added_to_group)
