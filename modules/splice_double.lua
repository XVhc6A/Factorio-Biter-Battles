-- biters splice into two -- by mewmew

local event = require("utils.event")

local biter_fragmentation = {
	["medium-biter"] = "small-biter",
	["big-biter"] = "medium-biter",
	["behemoth-biter"] = "big-biter",
}

local function on_entity_died(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/splice_double.lua:10')
	if not event.entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/splice_double.lua:12')
		return
	end
	if biter_fragmentation[event.entity.name] then
		local entity = event.entity
		for x = 1, 2, 1 do
			local p =
				entity.surface.find_non_colliding_position(biter_fragmentation[entity.name], entity.position, 3, 0.5)
			if p then
				entity.surface.create_entity({ name = biter_fragmentation[entity.name], position = p })
			end
		end
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/splice_double.lua:23')
		return
	end
end

event.add(defines.events.on_entity_died, on_entity_died)
