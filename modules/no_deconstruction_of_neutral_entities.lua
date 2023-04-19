local blacklist = {
	["cliff"] = true,
	["item-entity"] = true,
}

local function on_marked_for_deconstruction(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_deconstruction_of_neutral_entities.lua:5')
	local entity = event.entity
	if not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_deconstruction_of_neutral_entities.lua:8')
		return
	end
	if not event.player_index then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_deconstruction_of_neutral_entities.lua:11')
		return
	end
	if entity.force.name ~= "neutral" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_deconstruction_of_neutral_entities.lua:14')
		return
	end
	if blacklist[entity.type] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_deconstruction_of_neutral_entities.lua:17')
		return
	end
	entity.cancel_deconstruction(game.players[event.player_index].force.name)
end

local Event = require("utils.event")
Event.add(defines.events.on_marked_for_deconstruction, on_marked_for_deconstruction)
