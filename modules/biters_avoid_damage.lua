-- enemy biters have pseudo double hp -- by mewmew

local event = require("utils.event")

local function on_entity_damaged(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biters_avoid_damage.lua:4')
	if not event.entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biters_avoid_damage.lua:6')
		return
	end
	if math.random(1, 2) == 1 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biters_avoid_damage.lua:9')
		return
	end
	if event.entity.type ~= "unit" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biters_avoid_damage.lua:12')
		return
	end
	if event.final_damage_amount > event.entity.prototype.max_health then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biters_avoid_damage.lua:15')
		return
	end
	event.entity.health = event.entity.health + event.final_damage_amount
end

event.add(defines.events.on_entity_damaged, on_entity_damaged)
