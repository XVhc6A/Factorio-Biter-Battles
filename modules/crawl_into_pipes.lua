--Your character may enter pipes.

local Global = require("utils.global")
local Event = require("utils.event")

local math_floor = math.floor

local pipe_crawl = {}
Global.register(pipe_crawl, function(tbl)
	pipe_crawl = tbl
end)

local function get_current_pipe(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:12')
	local position = { math_floor(player.position.x) + 0.5, math_floor(player.position.y) + 0.5 }
	local pipe = player.surface.find_entities_filtered({
		type = { "pipe", "pipe-to-ground" },
		position = position,
		limit = 1,
	})[1]
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:19')
	return pipe
end

local function is_pipe_end_piece(pipe)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:22')
	local neighbours = pipe.neighbours[1]
	if #neighbours == 1 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:25')
		return true
	end
end

local function enter_pipe(player, pipe)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:29')
	if not is_pipe_end_piece(pipe) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:31')
		return
	end

	player.walking_state = { walking = false }
	pipe_crawl[player.name].character =
		player.character.clone({ position = { 0, 0 }, surface = "crawl_into_pipes", force = player.force })
	player.character.destroy()
	player.set_controller({ type = defines.controllers.god })
end

local function exit_pipe(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:41')
	if player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:43')
		return
	end
	local saved_character = pipe_crawl[player.name].character
	player.character =
		saved_character.clone({ position = player.position, surface = player.surface, force = player.force })
	saved_character.destroy()
end
--[[
local function align_position_to_pipe(player, pipe)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:51')
	local position = player.position
	local tile_position = {x = math_floor(position.x), y = math_floor(position.y)}
	local inside_position = {x = position.x - tile_position.x, y = position.y - tile_position.y}

end
]]
local function on_player_changed_position(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:58')
	local player = game.players[event.player_index]
	local pipe = get_current_pipe(player)
	if not pipe then
		exit_pipe(player)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:63')
		return
	end
	--[[
	if not player.character then 
		align_position_to_pipe(player, pipe)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:68')
		return 
	end
	]]
	if not player.character.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:72')
		return
	end
	if player.character.driving then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:75')
		return
	end

	enter_pipe(player, pipe)
end

local function on_player_joined_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:81')
	local player = game.players[event.player_index]
	if not pipe_crawl[player.name] then
		pipe_crawl[player.name] = {}
	end
end

local function on_init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/crawl_into_pipes.lua:88')
	pipe_crawl.players = {}

	game.create_surface("crawl_into_pipes", {
		height = 3,
		width = 3,
		["default_enable_all_autoplace_controls"] = false,
		["autoplace_settings"] = {
			["entity"] = { treat_missing_as_default = false },
			["tile"] = { treat_missing_as_default = false },
			["decorative"] = { treat_missing_as_default = false },
		},
	})
end

Event.on_init(on_init)
Event.add(defines.events.on_player_changed_position, on_player_changed_position)
Event.add(defines.events.on_player_joined_game, on_player_joined_game)
