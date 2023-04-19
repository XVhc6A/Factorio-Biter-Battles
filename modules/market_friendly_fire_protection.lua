local event = require("utils.event")

local function on_entity_damaged(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/market_friendly_fire_protection.lua:2')
	if event.entity.name ~= "market" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/market_friendly_fire_protection.lua:4')
		return false
	end
	if event.cause then
		if event.cause.force.name == "enemy" then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/market_friendly_fire_protection.lua:8')
			return false
		end
	end
	event.entity.health = event.entity.health + event.final_damage_amount
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/market_friendly_fire_protection.lua:12')
	return true
end

event.add(defines.events.on_entity_damaged, on_entity_damaged)
