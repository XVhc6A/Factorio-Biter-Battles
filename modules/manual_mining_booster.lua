--manually mining continuously will speed it up

local event = require("utils.event")

local valid_entities = {
	["rock-big"] = true,
	["rock-huge"] = true,
	["sand-rock-big"] = true,
}

local function mining_speed_cooldown(p)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/manual_mining_booster.lua:10')
	if not global.manual_mining_booster[p.index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/manual_mining_booster.lua:12')
		return
	end
	if game.tick - global.manual_mining_booster[p.index] < 180 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/manual_mining_booster.lua:15')
		return
	end
	--if not p.character then p.character.character_mining_speed_modifier = 0 return end
	if not p.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/manual_mining_booster.lua:19')
		return
	end
	p.character.character_mining_speed_modifier = p.character.character_mining_speed_modifier - 1
	if p.character.character_mining_speed_modifier <= 0 then
		p.character.character_mining_speed_modifier = 0
		global.manual_mining_booster[p.index] = nil
	end
end

local function on_player_mined_entity(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/manual_mining_booster.lua:28')
	if not valid_entities[event.entity.name] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/manual_mining_booster.lua:30')
		return
	end
	local player = game.players[event.player_index]
	player.character.character_mining_speed_modifier = player.character.character_mining_speed_modifier
		+ (math.random(25, 50) * 0.01)
	if player.character.character_mining_speed_modifier > 10 then
		player.character.character_mining_speed_modifier = 10
	end
	global.manual_mining_booster[event.player_index] = game.tick
end

local function tick()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/manual_mining_booster.lua:41')
	for _, p in pairs(game.connected_players) do
		mining_speed_cooldown(p)
	end
end

local function on_init(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/manual_mining_booster.lua:47')
	global.manual_mining_booster = {}
end

event.add(defines.events.on_player_mined_entity, on_player_mined_entity)
event.on_nth_tick(60, tick)
event.on_init(on_init)
