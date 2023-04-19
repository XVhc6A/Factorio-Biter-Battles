-- All entities that own a unit_number of a chosen force gain damage resistance.
-- ignores entity health regeneration

-- Use Public.set_health_modifier(force_index, modifier) to modify health.
-- 1 = original health, 2 = 200% total health, 4 = 400% total health,..

local Global = require("utils.global")
local Event = require("utils.event")
local Public = {}

local math_round = math.round

local fhb = {}
Global.register(fhb, function(tbl)
	fhb = tbl
end)

function Public.set_health_modifier(force_index, modifier)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:17')
	if not game.forces[force_index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:19')
		return
	end
	if not modifier then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:22')
		return
	end
	if not fhb[force_index] then
		fhb[force_index] = {}
	end
	fhb[force_index].m = math_round(1 / modifier, 4)
end

function Public.reset_tables()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:30')
	for k, v in pairs(fhb) do
		fhb[k] = nil
	end
end

local function on_entity_damaged(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:36')
	local entity = event.entity
	if not entity and not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:39')
		return
	end
	local unit_number = entity.unit_number
	if not unit_number then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:43')
		return
	end

	local boost = fhb[entity.force.index]
	if not boost then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:48')
		return
	end
	if not boost[unit_number] then
		boost[unit_number] = entity.prototype.max_health
	end

	local new_health = boost[unit_number] - event.final_damage_amount * boost.m
	boost[unit_number] = new_health
	entity.health = new_health
end

local function on_entity_died(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:59')
	local entity = event.entity
	if not entity and not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:62')
		return
	end
	local unit_number = entity.unit_number
	if not unit_number then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:66')
		return
	end
	local boost = fhb[entity.force.index]
	if not boost then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:70')
		return
	end
	boost[unit_number] = nil
end

local function on_player_repaired_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:75')
	local entity = event.entity
	if not entity and not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:78')
		return
	end
	local unit_number = entity.unit_number
	if not unit_number then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:82')
		return
	end
	local boost = fhb[entity.force.index]
	if not boost then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:86')
		return
	end
	boost[unit_number] = entity.health
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:91')
	Public.reset_tables()
end

Event.on_init(on_init)
Event.add(defines.events.on_entity_damaged, on_entity_damaged)
Event.add(defines.events.on_entity_died, on_entity_died)
Event.add(defines.events.on_player_repaired_entity, on_player_repaired_entity)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/force_health_booster.lua:100')
return Public
