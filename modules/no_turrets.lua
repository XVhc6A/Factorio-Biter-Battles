local turret_types = {
	["ammo-turret"] = true,
	["artillery-turret"] = true,
	["electric-turret"] = true,
	["fluid-turret"] = true,
}

local function destroy_turret(entity)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_turrets.lua:7')
	if not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_turrets.lua:9')
		return
	end
	if not turret_types[entity.type] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_turrets.lua:12')
		return
	end
	entity.die()
end

local function on_built_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_turrets.lua:17')
	destroy_turret(event.created_entity)
end

local function on_robot_built_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_turrets.lua:21')
	destroy_turret(event.created_entity)
end

local event = require("utils.event")
event.add(defines.events.on_built_entity, on_built_entity)
event.add(defines.events.on_robot_built_entity, on_robot_built_entity)
