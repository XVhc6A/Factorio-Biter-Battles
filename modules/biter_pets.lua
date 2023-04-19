local math_random = math.random
local nom_msg = { "munch", "munch", "yum" }

local Public = {}

local function feed_floaty_text(unit)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:5')
	unit.surface.create_entity({
		name = "flying-text",
		position = unit.position,
		text = nom_msg[math_random(1, #nom_msg)],
		color = { math_random(50, 100), 0, 255 },
	})
end

local function floaty_hearts(entity, c)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:14')
	local position = { x = entity.position.x - 0.75, y = entity.position.y - 1 }
	local b = 1.35
	for a = 1, c, 1 do
		local p = {
			(position.x + 0.4) + (b * -1 + math_random(0, b * 20) * 0.1),
			position.y + (b * -1 + math_random(0, b * 20) * 0.1),
		}
		entity.surface.create_entity({
			name = "flying-text",
			position = p,
			text = "♥",
			color = { math_random(150, 255), 0, 255 },
		})
	end
end

local function tame_unit_effects(player, entity)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:31')
	floaty_hearts(entity, 7)

	rendering.draw_text({
		text = "~" .. player.name .. "'s pet~",
		surface = player.surface,
		target = entity,
		target_offset = { 0, -2.6 },
		color = {
			r = player.color.r * 0.6 + 0.25,
			g = player.color.g * 0.6 + 0.25,
			b = player.color.b * 0.6 + 0.25,
			a = 1,
		},
		scale = 1.05,
		font = "default-large-semibold",
		alignment = "center",
		scale_with_zoom = false,
	})
end

local function find_unit(player, entity)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:52')
	local units = player.surface.find_entities_filtered({
		type = "unit",
		area = { { entity.position.x - 1, entity.position.y - 1 }, { entity.position.x + 1, entity.position.y + 1 } },
		limit = 1,
	})
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:58')
	return units[1]
end

local function feed_pet(unit)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:61')
	if unit.prototype.max_health == unit.health then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:63')
		return
	end
	unit.health = unit.health + 8 + math.floor(unit.prototype.max_health * 0.05)
	feed_floaty_text(unit)
	floaty_hearts(unit, math_random(1, 2))
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:68')
	return true
end

local function is_valid_player(player, unit)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:71')
	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:73')
		return
	end
	if not player.character.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:76')
		return
	end
	if player.surface.index ~= unit.surface.index then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:79')
		return
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:81')
	return true
end

function Public.biter_pets_tame_unit(player, unit, forced)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:84')
	if global.biter_pets[player.index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:86')
		return false
	end
	if not forced then
		if math_random(1, math.floor(unit.prototype.max_health * 0.01) + 1) ~= 1 then
			feed_floaty_text(unit)
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:91')
			return true
		end
	end
	if unit.force.index == player.force.index then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:95')
		return false
	end
	unit.ai_settings.allow_destroy_when_commands_fail = false
	unit.ai_settings.allow_try_return_to_spawner = false
	unit.force = player.force
	unit.set_command({ type = defines.command.wander, distraction = defines.distraction.by_enemy })
	global.biter_pets[player.index] = { last_command = 0, entity = unit }
	tame_unit_effects(player, unit)
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:103')
	return true
end

function Public.tame_unit_for_closest_player(unit)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:106')
	local valid_players = {}
	for _, player in pairs(game.connected_players) do
		if is_valid_player(player, unit) then
			table.insert(valid_players, player)
		end
	end

	local nearest_player = valid_players[1]
	if not nearest_player then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:116')
		return
	end

	for i = 2, #valid_players, 1 do
		local player = valid_players[i + 1]
		if
			player.position.x ^ 2 + player.position.y ^ 2
			< nearest_player.position.x ^ 2 + nearest_player.position.y ^ 2
		then
			nearest_player = spawner
		end
	end

	Public.biter_pets_tame_unit(nearest_player, unit, true)
end

local function command_unit(entity, player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:132')
	local square_distance = (player.position.x - entity.position.x) ^ 2 + (player.position.y - entity.position.y) ^ 2

	--Pet will follow, if the player is between a distance of 8 to 160 tiles away from it.
	if square_distance < 64 or square_distance > 25600 then
		entity.set_command({ type = defines.command.wander, distraction = defines.distraction.by_enemy })
	else
		entity.set_command({
			type = defines.command.go_to_location,
			destination_entity = player.character,
			radius = 4,
			distraction = defines.distraction.by_damage,
		})
	end
end

local function on_player_changed_position(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:148')
	if math_random(1, 100) ~= 1 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:150')
		return
	end
	local player = game.players[event.player_index]
	if not global.biter_pets[player.index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:154')
		return
	end
	if not global.biter_pets[player.index].entity then
		global.biter_pets[player.index] = nil
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:158')
		return
	end
	if not global.biter_pets[player.index].entity.valid then
		global.biter_pets[player.index] = nil
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:162')
		return
	end
	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:165')
		return
	end
	if global.biter_pets[player.index].last_command + 600 > game.tick then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:168')
		return
	end
	global.biter_pets[player.index].last_command = game.tick
	command_unit(global.biter_pets[player.index].entity, player)
end

local function on_player_dropped_item(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:174')
	local player = game.players[event.player_index]
	if event.entity.stack.name ~= "raw-fish" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:177')
		return
	end
	local unit = find_unit(player, event.entity)
	if not unit then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:181')
		return
	end
	if Public.biter_pets_tame_unit(player, unit, false) then
		event.entity.destroy()
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:185')
		return
	end
	if unit.force.index == player.force.index then
		feed_pet(unit)
	end
end

local function on_init(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:192')
	global.biter_pets = {}
end

local event = require("utils.event")
event.on_init(on_init)
event.add(defines.events.on_player_dropped_item, on_player_dropped_item)
event.add(defines.events.on_player_changed_position, on_player_changed_position)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/biter_pets.lua:201')
return Public
