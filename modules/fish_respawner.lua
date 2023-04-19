-- this module respawns fish in all water tiles on every surface with a player on it -- by mewmew --
-- cpu heavy -- fixed processing rate is 1 chunk per tick

local respawn_interval = 7200 --interval in ticks
global.fish_respawner_water_tiles_per_fish = 32 --amount of water tiles required per fish >> high values = less fish density, low values = high fish density
global.fish_respawner_max_respawnrate_per_chunk = 1 --maximum amount of fish that will spawn each interval in one chunk

local valid_water_tiles = {
	"water",
	"deepwater",
	"water-green",
	"deepwater-green",
}

local event = require("utils.event")
local math_random = math.random

local function shuffle(tbl)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:17')
	local size = #tbl
	for i = size, 1, -1 do
		local rand = math_random(size)
		tbl[i], tbl[rand] = tbl[rand], tbl[i]
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:23')
	return tbl
end

local function get_surfaces()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:26')
	local surfaces = {}
	for _, player in pairs(game.connected_players) do
		if not surfaces[player.surface.index] then
			surfaces[player.surface.index] = player.surface
		end
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:33')
	return surfaces
end

local function create_new_fish_spawn_schedule()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:36')
	global.fish_respawn_chunk_schedule = {}

	local surfaces = get_surfaces()
	if #surfaces == 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:41')
		return
	end

	for _, surface in pairs(surfaces) do
		for chunk in surface.get_chunks() do
			global.fish_respawn_chunk_schedule[#global.fish_respawn_chunk_schedule + 1] =
				{ chunk = { x = chunk.x, y = chunk.y }, surface_index = surface.index }
		end
	end

	global.fish_respawn_chunk_schedule = shuffle(global.fish_respawn_chunk_schedule)

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:53')
	return global.fish_respawn_chunk_schedule
end

local function respawn_fishes_in_chunk(schedule)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:56')
	local surface = game.surfaces[schedule.surface_index]
	local chunk = schedule.chunk
	local chunk_area = { { chunk.x * 32, chunk.y * 32 }, { chunk.x * 32 + 32, chunk.y * 32 + 32 } }

	local water_tiles = surface.find_tiles_filtered({ area = chunk_area, name = valid_water_tiles })
	if #water_tiles < global.fish_respawner_water_tiles_per_fish then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:63')
		return
	end

	local chunk_fish_count = surface.count_entities_filtered({ area = chunk_area, type = "fish" })

	local fish_to_spawn = math.floor(
		(#water_tiles - (global.fish_respawner_water_tiles_per_fish * chunk_fish_count))
			/ global.fish_respawner_water_tiles_per_fish
	)
	if fish_to_spawn <= 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:73')
		return
	end

	if fish_to_spawn > global.fish_respawner_max_respawnrate_per_chunk then
		fish_to_spawn = global.fish_respawner_max_respawnrate_per_chunk
	end

	water_tiles = shuffle(water_tiles)
	for _, tile in pairs(water_tiles) do
		if surface.can_place_entity({ name = "fish", position = tile.position }) then
			surface.create_entity({ name = "water-splash", position = tile.position })
			surface.create_entity({ name = "fish", position = tile.position })
			fish_to_spawn = fish_to_spawn - 1
			if fish_to_spawn <= 0 then
				log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:87')
				return
			end
		end
	end
end

local function on_tick()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:93')
	local i = game.tick % respawn_interval
	if i == 0 then
		create_new_fish_spawn_schedule()
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:97')
		return
	end
	if not global.fish_respawn_chunk_schedule[i] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/fish_respawner.lua:100')
		return
	end
	respawn_fishes_in_chunk(global.fish_respawn_chunk_schedule[i])
	global.fish_respawn_chunk_schedule[i] = nil
end

event.add(defines.events.on_tick, on_tick)
