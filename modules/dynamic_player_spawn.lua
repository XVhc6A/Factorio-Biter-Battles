-- this automatically sets player's force spawn point to where a lot of buildings are

local event = require("utils.event")

local valid_types = { "boiler", "furnace", "generator", "offshore-pump", "lab", "assembling-machine" }

local function on_built_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/dynamic_player_spawn.lua:6')
	if not event.created_entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/dynamic_player_spawn.lua:8')
		return
	end
	local player = game.players[event.player_index]
	local area = {
		{ event.created_entity.position.x - 12, event.created_entity.position.y - 12 },
		{ event.created_entity.position.x + 12, event.created_entity.position.y + 12 },
	}
	if player.surface.count_entities_filtered({ area = area, force = player.force, type = valid_types }) > 12 then
		player.force.set_spawn_position(player.position, player.surface)
	end
end

event.add(defines.events.on_built_entity, on_built_entity)
