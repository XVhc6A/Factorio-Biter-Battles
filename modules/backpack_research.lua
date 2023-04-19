-- backpack research -- researching mining efficiency increases your backpack capacity (inventory slots)

local event = require("utils.event")

local function on_research_finished(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/backpack_research.lua:4')
	event.research.force.character_inventory_slots_bonus = game.forces.player.mining_drill_productivity_bonus * 100
end

event.add(defines.events.on_research_finished, on_research_finished)
