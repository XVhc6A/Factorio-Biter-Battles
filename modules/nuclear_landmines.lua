local math_random = math.random

local function detonate_nuke(entity)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/nuclear_landmines.lua:2')
	local surface = entity.surface
	surface.create_entity({
		name = "atomic-rocket",
		position = entity.position,
		force = entity.force,
		speed = 1,
		max_range = 800,
		target = entity,
		source = entity,
	})
end

local function on_entity_died(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/nuclear_landmines.lua:15')
	local entity = event.entity
	if not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/nuclear_landmines.lua:18')
		return
	end
	if entity.name == "land-mine" then
		if math_random(1, global.nuclear_landmines.chance) == 1 then
			detonate_nuke(entity)
		end
	end
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/nuclear_landmines.lua:27')
	global.nuclear_landmines = {}
	global.nuclear_landmines.chance = 512
end

local Event = require("utils.event")
Event.on_init(on_init)
Event.add(defines.events.on_entity_died, on_entity_died)
