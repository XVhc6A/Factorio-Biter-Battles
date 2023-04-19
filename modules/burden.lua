local Event = require("utils.event")
local Modifier = require("player_modifiers")
local Color = require("utils.color_presets")

local function validate_player(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:4')
	if not player then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:6')
		return false
	end
	if not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:9')
		return false
	end
	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:12')
		return false
	end
	if not player.connected then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:15')
		return false
	end
	if not game.players[player.name] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:18')
		return false
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:20')
	return true
end

local function compute_fullness(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:23')
	local inv = player.get_inventory(defines.inventory.character_main)
	local max_stacks = #inv
	local num_stacks = 0

	local contents = inv.get_contents()
	for item, count in pairs(contents) do
		local stack_size = 1
		if game.item_prototypes[item].stackable then
			stack_size = game.item_prototypes[item].stack_size
		end

		num_stacks = num_stacks + count / stack_size
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:38')
	return num_stacks / max_stacks
end

local function check_burden(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:41')
	local player_modifiers = Modifier.get_table()
	local player = game.players[event.player_index]
	if not validate_player(player) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:45')
		return
	end
	local fullness = compute_fullness(player)
	player_modifiers[player.index].character_running_speed_modifier["randomness"] = 0.3 - fullness
	player_modifiers[player.index].character_mining_speed_modifier["randomess"] = 0.3 - fullness
	Modifier.update_player_modifiers(player)
	if fullness >= 0.9 and fullness <= 0.901 then
		player.print("Maybe you should drop some of that inventory to lessen the burden.", Color.red)
	end
end

local function on_init(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:56')
	script.on_event(defines.events.on_player_main_inventory_changed, check_burden)
end

local function on_load(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/burden.lua:60')
	script.on_event(defines.events.on_player_main_inventory_changed, check_burden)
end

Event.on_init(on_init)
Event.on_load(on_load)
