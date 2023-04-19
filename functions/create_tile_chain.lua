local function shuffle(tbl)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_tile_chain.lua:0')
	local size = #tbl
	for i = size, 1, -1 do
		local rand = math.random(size)
		tbl[i], tbl[rand] = tbl[rand], tbl[i]
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_tile_chain.lua:6')
	return tbl
end

local function create_tile_chain(surface, tile, count, straightness)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_tile_chain.lua:9')
	if not surface then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_tile_chain.lua:11')
		return
	end
	if not tile then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_tile_chain.lua:14')
		return
	end
	if not count then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_tile_chain.lua:17')
		return
	end

	local position = { x = tile.position.x, y = tile.position.y }

	local modifiers = {
		{ x = 0, y = -1 },
		{ x = -1, y = 0 },
		{ x = 1, y = 0 },
		{ x = 0, y = 1 },
		{ x = -1, y = 1 },
		{ x = 1, y = -1 },
		{ x = 1, y = 1 },
		{ x = -1, y = -1 },
	}
	modifiers = shuffle(modifiers)

	for a = 1, count, 1 do
		local tile_placed = false

		if math.random(0, 100) > straightness then
			modifiers = shuffle(modifiers)
		end
		for b = 1, 4, 1 do
			local pos = { x = position.x + modifiers[b].x, y = position.y + modifiers[b].y }
			if surface.get_tile(pos).name ~= tile.name then
				surface.set_tiles({ { name = tile.name, position = pos } }, true)
				position = { x = pos.x, y = pos.y }
				tile_placed = true
				break
			end
		end

		if not tile_placed then
			position = { x = position.x + modifiers[1].x, y = position.y + modifiers[1].y }
		end
	end
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/functions/create_tile_chain.lua:56')
return create_tile_chain
