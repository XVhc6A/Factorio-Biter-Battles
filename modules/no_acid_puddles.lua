local r = 1.5

local acid_puddles = {
	"acid-splash-fire-spitter-behemoth",
	"acid-splash-fire-spitter-big",
	"acid-splash-fire-spitter-medium",
	"acid-splash-fire-spitter-small",
	"acid-splash-fire-worm-behemoth",
	"acid-splash-fire-worm-big",
	"acid-splash-fire-worm-medium",
	"acid-splash-fire-worm-small",
}

local valid_enemies = {
	["small-spitter"] = true,
	["medium-spitter"] = true,
	["big-spitter"] = true,
	["behemoth-spitter"] = true,
	["small-worm-turret"] = true,
	["medium-worm-turret"] = true,
	["big-worm-turret"] = true,
	["behemoth-worm-turret"] = true,
}

local function remove_puddles(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_acid_puddles.lua:24')
	local cause = event.cause
	if not cause then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_acid_puddles.lua:27')
		return true
	end
	if not cause.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_acid_puddles.lua:30')
		return true
	end
	if valid_enemies[cause.name] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_acid_puddles.lua:33')
		return true
	end
end

local function on_entity_damaged(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_acid_puddles.lua:37')
	if not remove_puddles(event) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_acid_puddles.lua:39')
		return
	end
	local entity = event.entity
	if not entity or not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/no_acid_puddles.lua:43')
		return
	end
	local position = entity.position
	for _, puddle in
		pairs(entity.surface.find_entities_filtered({
			name = acid_puddles,
			area = { { position.x - r, position.y - r }, { position.x + r, position.y + r } },
		}))
	do
		puddle.destroy()
	end
end

local Event = require("utils.event")
Event.add(defines.events.on_entity_damaged, on_entity_damaged)
