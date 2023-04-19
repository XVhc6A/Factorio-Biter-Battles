local function shuffle(tbl)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_entity_chain.lua:0')
	local size = #tbl
	for i = size, 1, -1 do
		local rand = math.random(size)
		tbl[i], tbl[rand] = tbl[rand], tbl[i]
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_entity_chain.lua:6')
	return tbl
end

local function create_entity_chain(surface, entity, count, straightness)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_entity_chain.lua:9')
	if not surface then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_entity_chain.lua:11')
		return
	end
	if not entity then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_entity_chain.lua:14')
		return
	end
	if not count then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_entity_chain.lua:17')
		return
	end

	local position = { x = entity.position.x, y = entity.position.y }

	local modifiers = { { x = 0, y = -1 }, { x = -1, y = 0 }, { x = 1, y = 0 }, { x = 0, y = 1 } }
	local modifiers_d = { { x = -1, y = 1 }, { x = 1, y = -1 }, { x = 1, y = 1 }, { x = -1, y = -1 } }

	modifiers = shuffle(modifiers)
	modifiers_d = shuffle(modifiers_d)

	for a = 1, count, 1 do
		local entity_placed = false

		if math.random(0, 100) > straightness then
			modifiers = shuffle(modifiers)
		end
		for b = 1, 4, 1 do
			local pos = { x = position.x + modifiers[b].x, y = position.y + modifiers[b].y }
			if surface.can_place_entity({ name = entity.name, position = pos }) then
				surface.create_entity({ name = entity.name, position = pos, force = entity.force })
				position = { x = pos.x, y = pos.y }
				entity_placed = true
				break
			end
		end

		if not entity_placed then
			if math.random(0, 100) > straightness then
				modifiers_d = shuffle(modifiers_d)
			end
			for b = 1, 4, 1 do
				local pos = { x = position.x + modifiers_d[b].x, y = position.y + modifiers_d[b].y }
				if surface.can_place_entity({ name = entity.name, position = pos }) then
					surface.create_entity({ name = entity.name, position = pos, force = entity.force })
					position = { x = pos.x, y = pos.y }
					entity_placed = true
					break
				end
			end
		end

		if not entity_placed then
			position = { x = position.x + modifiers[1].x, y = position.y + modifiers[1].y }
		end
	end
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_entity_chain.lua:65')
return create_entity_chain
