local event = require("utils.event")

local coin_yield = {
	["rock-big"] = 3,
	["rock-huge"] = 6,
	["sand-rock-big"] = 3,
}

local function on_player_mined_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rocks_yield_coins.lua:8')
	if coin_yield[event.entity.name] then
		event.entity.surface.spill_item_stack(event.entity.position, {
			name = "coin",
			count = math.random(
				math.ceil(coin_yield[event.entity.name] * 0.5),
				math.ceil(coin_yield[event.entity.name] * 2)
			),
		}, true)
	end
end

event.add(defines.events.on_player_mined_entity, on_player_mined_entity)
