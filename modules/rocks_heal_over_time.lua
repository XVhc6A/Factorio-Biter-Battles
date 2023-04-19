-- rocks and other entities heal over time -- by mewmew

local entity_whitelist = {
	["rock-big"] = true,
	["sand-rock-big"] = true,
	["rock-huge"] = true,
	["mineable-wreckage"] = true,
}

local function process_entity(v, key)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rocks_heal_over_time.lua:9')
	if not v.entity then
		global.entities_regenerate_health[key] = nil
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rocks_heal_over_time.lua:12')
		return
	end
	if not v.entity.valid then
		global.entities_regenerate_health[key] = nil
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rocks_heal_over_time.lua:16')
		return
	end

	if v.last_damage + 36000 < game.tick then
		v.entity.health = v.entity.health + math.floor(v.entity.prototype.max_health * 0.02)
		if v.entity.prototype.max_health == v.entity.health then
			global.entities_regenerate_health[key] = nil
		end
	end
end

local function on_entity_damaged(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rocks_heal_over_time.lua:27')
	if not event.entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rocks_heal_over_time.lua:29')
		return
	end
	if event.entity.force.index ~= 3 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rocks_heal_over_time.lua:32')
		return
	end
	if not entity_whitelist[event.entity.name] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rocks_heal_over_time.lua:35')
		return
	end
	global.entities_regenerate_health[tostring(event.entity.position.x) .. "_" .. tostring(event.entity.position.y)] =
		{ last_damage = game.tick, entity = event.entity }
end

local function tick(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rocks_heal_over_time.lua:41')
	for key, entity in pairs(global.entities_regenerate_health) do
		process_entity(entity, key)
	end
end

local function on_init(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rocks_heal_over_time.lua:47')
	global.entities_regenerate_health = {}
end

local event = require("utils.event")
event.on_nth_tick(1800, tick)
event.on_init(on_init)
event.add(defines.events.on_entity_damaged, on_entity_damaged)
