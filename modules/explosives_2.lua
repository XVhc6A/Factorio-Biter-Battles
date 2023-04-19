local Public = {}

local Global = require("utils.global")
local explosives = {}
Global.register(explosives, function(tbl)
	explosives = tbl
end)

local explosives_effects = {
	"explosion",
	"grenade-explosion",
	"explosion",
	"grenade-explosion",
	"big-artillery-explosion",
	"massive-explosion",
	"land-mine-explosion",
	"storage-tank-explosion",
}
local table_insert = table.insert
local table_remove = table.remove
local math_floor = math.floor
local math_sqrt = math.sqrt
local math_random = math.random
local speed = 6
local valid_container_types = {
	["car"] = true,
	["cargo-wagon"] = true,
	["container"] = true,
	["logistic-container"] = true,
	["spider-vehicle"] = true,
}

local maximum_radius = 64
local explosive_vectors = {}
for x = maximum_radius * -1, maximum_radius, 1 do
	for y = maximum_radius * -1, maximum_radius, 1 do
		local d = math_floor(math_sqrt(x ^ 2 + y ^ 2)) + 1
		if d <= maximum_radius then
			if not explosive_vectors[d] then
				explosive_vectors[d] = {}
			end
			table_insert(explosive_vectors[d], { x, y })
		end
	end
end

local function draw_effects(surface, instance)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:46')
	local vectors = explosive_vectors[instance.current_r]
	if not vectors then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:49')
		return
	end
	local center_position_x = instance.position.x
	local center_position_y = instance.position.y
	for _, v in pairs(vectors) do
		if math_random(0, instance.current_r * 0.15 * (explosives.instance_count * 0.5)) == 0 then
			local position = { center_position_x + v[1], center_position_y + v[2] }
			local name = explosives_effects[math_random(1, 8)]
			surface.create_entity({ name = name, position = position, target = position })
		end
	end
end

local function damage_entity(entity, amount)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:62')
	if not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:64')
		return
	end
	if not entity.health then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:67')
		return
	end
	if entity.health <= 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:70')
		return
	end
	if not entity.destructible then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:73')
		return
	end
	entity.damage(amount, "player", "explosion")
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:76')
	return true
end

local function damage_entities(surface, instance)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:79')
	local vectors = explosive_vectors[instance.current_r]
	if not vectors then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:82')
		return
	end
	local center_position_x = instance.position.x
	local center_position_y = instance.position.y
	for _, v in pairs(vectors) do
		local position = { center_position_x + v[1], center_position_y + v[2] }
		for _, entity in
			pairs(surface.find_entities_filtered({
				area = { position, { position[1] + 1, position[2] + 1 } },
				type = { "corpse", "explosion" },
				invert = true,
			}))
		do
			if instance.damage_remaining < 200 then
				if damage_entity(entity, instance.damage_remaining) then
					log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:97')
					return
				end
			else
				if damage_entity(entity, 200) then
					instance.damage_remaining = instance.damage_remaining - 200
				end
			end
		end
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:106')
	return true
end

local function damage_tiles(surface, instance)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:109')
	local vectors = explosive_vectors[instance.current_r]
	if not vectors then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:112')
		return
	end
	local center_position_x = instance.position.x
	local center_position_y = instance.position.y
	local destructible_tiles = explosives.destructible_tiles
	for _, v in pairs(vectors) do
		local position = { center_position_x + v[1], center_position_y + v[2] }
		local tile = surface.get_tile(position)
		local tile_health = destructible_tiles[tile.name]
		if tile_health then
			if instance.damage_remaining < tile_health then
				log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:123')
				return
			end
			instance.damage_remaining = instance.damage_remaining - tile_health
			surface.set_tiles({ { name = "nuclear-ground", position = position } }, true, false, false, false)
		end
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:129')
	return true
end

local function process_explosion(instance)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:132')
	local surface = game.surfaces[instance.surface_index]
	if not surface then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:135')
		return
	end
	if not surface.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:138')
		return
	end
	draw_effects(surface, instance)
	if not damage_entities(surface, instance) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:142')
		return
	end
	if not damage_tiles(surface, instance) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:145')
		return
	end
	instance.current_r = instance.current_r + 1
	if instance.current_r > instance.max_r then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:149')
		return
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:151')
	return true
end

function spawn_explosion(surface, position, amount)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:154')
	if not explosives.instances then
		explosives.instances = {}
	end
	table_insert(explosives.instances, {
		surface_index = surface.index,
		damage_remaining = amount * 500,
		position = position,
		current_r = 1,
		max_r = math_floor(amount / 50) + 5,
	})
end

local function on_tick()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:167')
	if not explosives.instances then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:169')
		return
	end
	explosives.instance_count = #explosives.instances
	for k, instance in pairs(explosives.instances) do
		local success = process_explosion(instance)
		if not success then
			table_remove(explosives.instances, k)
		end
	end
	if #explosives.instances == 0 then
		explosives.instances = nil
	end
end

local function on_entity_died(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:183')
	local entity = event.entity
	if not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:186')
		return
	end
	if not valid_container_types[entity.type] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:189')
		return
	end

	local inventory = defines.inventory.chest
	if entity.type == "car" or entity.type == "spider-vehicle" then
		inventory = defines.inventory.car_trunk
	end

	local i = entity.get_inventory(inventory)
	local amount = i.get_item_count("explosives")
	if not amount then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:200')
		return
	end
	if amount < 1 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:203')
		return
	end

	spawn_explosion(entity.surface, { x = entity.position.x, y = entity.position.y }, amount)
end

function Public.set_destructible_tile(tile_name, health)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:209')
	explosives.destructible_tiles[tile_name] = health
end

function Public.get_table()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:213')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:214')
	return explosives
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:217')
	explosives.destructible_tiles = {}
end

local Event = require("utils.event")
Event.on_init(on_init)
Event.on_nth_tick(speed, on_tick)
Event.add(defines.events.on_entity_died, on_entity_died)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/explosives_2.lua:226')
return Public
