local Task = require("utils.task")
local RPG = require("modules.rpg.table")
local Gui = require("utils.gui")
local Color = require("utils.color_presets")
local Token = require("utils.token")
local Alert = require("utils.alert")

local Public = {}

local level_up_floating_text_color = { 0, 205, 0 }
local visuals_delay = RPG.visuals_delay
local xp_floating_text_color = RPG.xp_floating_text_color
local experience_levels = RPG.experience_levels
local points_per_level = RPG.points_per_level

--RPG Frames
local main_frame_name = RPG.main_frame_name

local travelings = {
	"bzzZZrrt",
	"WEEEeeeeeee",
	"out of my way son",
	"on my way",
	"i need to leave",
	"comfylatron seeking target",
	"gotta go fast",
	"gas gas gas",
	"comfylatron coming through",
}

local desync = Token.register(function(data)
	local entity = data.entity
	if not entity or not entity.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:33')
		return
	end
	local surface = data.surface
	local fake_shooter = surface.create_entity({ name = "character", position = entity.position, force = "enemy" })
	for i = 1, 3 do
		surface.create_entity({
			name = "explosive-rocket",
			position = entity.position,
			force = "enemy",
			speed = 1,
			max_range = 1,
			target = entity,
			source = fake_shooter,
		})
	end
	if fake_shooter and fake_shooter.valid then
		fake_shooter.destroy()
	end
end)

local function create_healthbar(player, size)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:53')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:54')
	return rendering.draw_sprite({
		sprite = "virtual-signal/signal-white",
		tint = Color.green,
		x_scale = size * 8,
		y_scale = size - 0.2,
		render_layer = "light-effect",
		target = player.character,
		target_offset = { 0, -2.5 },
		surface = player.surface,
	})
end

local function create_manabar(player, size)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:66')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:67')
	return rendering.draw_sprite({
		sprite = "virtual-signal/signal-white",
		tint = Color.blue,
		x_scale = size * 8,
		y_scale = size - 0.2,
		render_layer = "light-effect",
		target = player.character,
		target_offset = { 0, -2.0 },
		surface = player.surface,
	})
end

local function set_bar(min, max, id, mana)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:79')
	local m = min / max
	if not rendering.is_valid(id) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:82')
		return
	end
	local x_scale = rendering.get_y_scale(id) * 8
	rendering.set_x_scale(id, x_scale * m)
	if not mana then
		rendering.set_color(id, { math.floor(255 - 255 * m), math.floor(200 * m), 0 })
	end
end

local function level_up(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:91')
	local rpg_t = RPG.get("rpg_t")
	local RPG_GUI = package.loaded["modules.rpg.gui"]
	local names = RPG.auto_allocate_nodes

	local distribute_points_gain = 0
	for i = rpg_t[player.index].level + 1, #experience_levels, 1 do
		if rpg_t[player.index].xp > experience_levels[i] then
			rpg_t[player.index].level = i
			distribute_points_gain = distribute_points_gain + points_per_level
		else
			break
		end
	end
	if distribute_points_gain == 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:106')
		return
	end
	RPG_GUI.draw_level_text(player)
	rpg_t[player.index].points_to_distribute = rpg_t[player.index].points_to_distribute + distribute_points_gain
	RPG_GUI.update_char_button(player)
	if rpg_t[player.index].allocate_index ~= 1 then
		local node = rpg_t[player.index].allocate_index
		local index = names[node]:lower()
		rpg_t[player.index][index] = rpg_t[player.index][index] + distribute_points_gain
		rpg_t[player.index].points_to_distribute = rpg_t[player.index].points_to_distribute - distribute_points_gain
		if not rpg_t[player.index].reset then
			rpg_t[player.index].total = rpg_t[player.index].total + distribute_points_gain
		end
		RPG_GUI.update_player_stats(player)
	end
	if player.gui.screen[main_frame_name] then
		RPG_GUI.toggle(player, true)
	end

	Public.level_up_effects(player)
end

local function add_to_global_pool(amount, personal_tax)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:128')
	local rpg_extra = RPG.get("rpg_extra")

	if not rpg_extra.global_pool then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:132')
		return
	end
	local fee
	if personal_tax then
		fee = amount * rpg_extra.personal_tax_rate
	else
		fee = amount * 0.3
	end

	rpg_extra.global_pool = rpg_extra.global_pool + fee
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:142')
	return amount - fee
end

function Public.suicidal_comfylatron(pos, surface)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:145')
	local str = travelings[math.random(1, #travelings)]
	local symbols = { "", "!", "!", "!!", ".." }
	str = str .. symbols[math.random(1, #symbols)]
	local text = str
	local e = surface.create_entity({
		name = "compilatron",
		position = { x = pos.x, y = pos.y + 2 },
		force = "neutral",
	})
	surface.create_entity({
		name = "compi-speech-bubble",
		position = e.position,
		source = e,
		text = text,
	})
	local nearest_player_unit =
		surface.find_nearest_enemy({ position = e.position, max_distance = 512, force = "player" })

	if nearest_player_unit and nearest_player_unit.active and nearest_player_unit.force.name ~= "player" then
		e.set_command({
			type = defines.command.attack,
			target = nearest_player_unit,
			distraction = defines.distraction.none,
		})
		local data = {
			entity = e,
			surface = surface,
		}
		Task.set_timeout_in_ticks(600, desync, data)
	else
		e.surface.create_entity({ name = "medium-explosion", position = e.position })
		e.surface.create_entity({
			name = "flying-text",
			position = e.position,
			text = "DeSyyNC - no target found!",
			color = { r = 150, g = 0, b = 0 },
		})
		e.die()
	end
end

function Public.validate_player(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:187')
	if not player then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:189')
		return false
	end
	if not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:192')
		return false
	end
	if not player.character then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:195')
		return false
	end
	if not player.connected then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:198')
		return false
	end
	if not game.players[player.index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:201')
		return false
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:203')
	return true
end

function Public.update_mana(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:206')
	local rpg_extra = RPG.get("rpg_extra")
	local rpg_t = RPG.get("rpg_t")
	if not rpg_extra.enable_mana then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:210')
		return
	end

	if not rpg_t[player.index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:214')
		return
	end

	if player.gui.screen[main_frame_name] then
		local f = player.gui.screen[main_frame_name]
		local data = Gui.get_data(f)
		if data.mana and data.mana.valid then
			data.mana.caption = rpg_t[player.index].mana
		end
	end

	if rpg_t[player.index].mana < 1 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:226')
		return
	end
	if rpg_extra.enable_health_and_mana_bars then
		if rpg_t[player.index].show_bars then
			if player.character and player.character.valid then
				if not rpg_t[player.index].mana_bar then
					rpg_t[player.index].mana_bar = create_manabar(player, 0.5)
				elseif not rendering.is_valid(rpg_t[player.index].mana_bar) then
					rpg_t[player.index].mana_bar = create_manabar(player, 0.5)
				end
				set_bar(rpg_t[player.index].mana, rpg_t[player.index].mana_max, rpg_t[player.index].mana_bar, true)
			end
		else
			if rpg_t[player.index].mana_bar then
				if rendering.is_valid(rpg_t[player.index].mana_bar) then
					rendering.destroy(rpg_t[player.index].mana_bar)
				end
			end
		end
	end
end

function Public.reward_mana(player, mana_to_add)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:248')
	local rpg_extra = RPG.get("rpg_extra")
	local rpg_t = RPG.get("rpg_t")
	if not rpg_extra.enable_mana then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:252')
		return
	end

	if not mana_to_add then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:256')
		return
	end

	if not rpg_t[player.index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:260')
		return
	end

	if player.gui.screen[main_frame_name] then
		local f = player.gui.screen[main_frame_name]
		local data = Gui.get_data(f)
		if data.mana and data.mana.valid then
			data.mana.caption = rpg_t[player.index].mana
		end
	end
	if rpg_t[player.index].mana_max < 1 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:271')
		return
	end

	if rpg_t[player.index].mana >= rpg_t[player.index].mana_max then
		rpg_t[player.index].mana = rpg_t[player.index].mana_max
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:276')
		return
	end

	rpg_t[player.index].mana = rpg_t[player.index].mana + mana_to_add
end

function Public.update_health(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:282')
	local rpg_extra = RPG.get("rpg_extra")
	local rpg_t = RPG.get("rpg_t")

	if not player or not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:287')
		return
	end

	if not player.character or not player.character.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:291')
		return
	end

	if not rpg_t[player.index] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:295')
		return
	end

	if player.gui.screen[main_frame_name] then
		local f = player.gui.screen[main_frame_name]
		local data = Gui.get_data(f)
		if data.health and data.health.valid then
			data.health.caption = (math.round(player.character.health * 10) / 10)
		end
		local shield_gui = player.character.get_inventory(defines.inventory.character_armor)
		if not shield_gui.is_empty() then
			if shield_gui[1].grid then
				local shield = math.floor(shield_gui[1].grid.shield)
				local shield_max = math.floor(shield_gui[1].grid.max_shield)
				if data.shield and data.shield.valid then
					data.shield.caption = shield
				end
				if data.shield_max and data.shield_max.valid then
					data.shield_max.caption = shield_max
				end
			end
		end
	end

	if rpg_extra.enable_health_and_mana_bars then
		if rpg_t[player.index].show_bars then
			local max_life = math.floor(
				player.character.prototype.max_health
					+ player.character_health_bonus
					+ player.force.character_health_bonus
			)
			if not rpg_t[player.index].health_bar then
				rpg_t[player.index].health_bar = create_healthbar(player, 0.5)
			elseif not rendering.is_valid(rpg_t[player.index].health_bar) then
				rpg_t[player.index].health_bar = create_healthbar(player, 0.5)
			end
			set_bar(player.character.health, max_life, rpg_t[player.index].health_bar)
		else
			if rpg_t[player.index].health_bar then
				if rendering.is_valid(rpg_t[player.index].health_bar) then
					rendering.destroy(rpg_t[player.index].health_bar)
				end
			end
		end
	end
end

function Public.level_limit_exceeded(player, value)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:342')
	local rpg_extra = RPG.get("rpg_extra")
	local rpg_t = RPG.get("rpg_t")
	if not rpg_extra.level_limit_enabled then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:346')
		return false
	end

	local limits = {
		[1] = 30,
		[2] = 50,
		[3] = 70,
		[4] = 90,
		[5] = 110,
		[6] = 130,
		[7] = 150,
		[8] = 170,
		[9] = 190,
		[10] = 210,
	}

	local level = rpg_t[player.index].level
	local zone = rpg_extra.breached_walls
	if zone >= 11 then
		zone = 10
	end
	if value then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:368')
		return limits[zone]
	end

	if level >= limits[zone] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:372')
		return true
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:374')
	return false
end

function Public.level_up_effects(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:377')
	local position = { x = player.position.x - 0.75, y = player.position.y - 1 }
	player.surface.create_entity({
		name = "flying-text",
		position = position,
		text = "+LVL ",
		color = level_up_floating_text_color,
	})
	local b = 0.75
	for _ = 1, 5, 1 do
		local p = {
			(position.x + 0.4) + (b * -1 + math.random(0, b * 20) * 0.1),
			position.y + (b * -1 + math.random(0, b * 20) * 0.1),
		}
		player.surface.create_entity({
			name = "flying-text",
			position = p,
			text = "✚",
			color = { 255, math.random(0, 100), 0 },
		})
	end
	player.play_sound({ path = "utility/achievement_unlocked", volume_modifier = 0.40 })
end

function Public.xp_effects(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:401')
	local position = { x = player.position.x - 0.75, y = player.position.y - 1 }
	player.surface.create_entity({
		name = "flying-text",
		position = position,
		text = "+XP",
		color = level_up_floating_text_color,
	})
	local b = 0.75
	for _ = 1, 5, 1 do
		local p = {
			(position.x + 0.4) + (b * -1 + math.random(0, b * 20) * 0.1),
			position.y + (b * -1 + math.random(0, b * 20) * 0.1),
		}
		player.surface.create_entity({
			name = "flying-text",
			position = p,
			text = "✚",
			color = { 255, math.random(0, 100), 0 },
		})
	end
	player.play_sound({ path = "utility/achievement_unlocked", volume_modifier = 0.40 })
end

function Public.get_melee_modifier(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:425')
	local rpg_t = RPG.get("rpg_t")
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:427')
	return (rpg_t[player.index].strength - 10) * 0.10
end

function Public.get_heal_modifier(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:430')
	local rpg_t = RPG.get("rpg_t")
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:432')
	return (rpg_t[player.index].vitality - 10) * 0.02
end

function Public.get_mana_modifier(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:435')
	local rpg_t = RPG.get("rpg_t")
	if rpg_t[player.index].level <= 40 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:438')
		return (rpg_t[player.index].magicka - 10) * 0.02000
	elseif rpg_t[player.index].level <= 80 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:440')
		return (rpg_t[player.index].magicka - 10) * 0.01800
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:442')
		return (rpg_t[player.index].magicka - 10) * 0.01400
	end
end

function Public.get_life_on_hit(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:446')
	local rpg_t = RPG.get("rpg_t")
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:448')
	return (rpg_t[player.index].vitality - 10) * 0.4
end

function Public.get_one_punch_chance(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:451')
	local rpg_t = RPG.get("rpg_t")
	if rpg_t[player.index].strength < 100 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:454')
		return 0
	end
	local chance = math.round(rpg_t[player.index].strength * 0.01, 1)
	if chance > 100 then
		chance = 100
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:460')
	return chance
end

function Public.get_magicka(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:463')
	local rpg_t = RPG.get("rpg_t")
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:465')
	return (rpg_t[player.index].magicka - 10) * 0.10
end

--- Gives connected player some bonus xp if the map was preemptively shut down.
-- amount (integer) -- 10 levels
-- local Public = require 'modules.rpg.functions' Public.give_xp(512)
function Public.give_xp(amount)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:471')
	for _, player in pairs(game.connected_players) do
		if not Public.validate_player(player) then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:474')
			return
		end
		Public.gain_xp(player, amount)
	end
end

function Public.rpg_reset_player(player, one_time_reset)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:480')
	if not player.character then
		player.set_controller({ type = defines.controllers.god })
		player.create_character()
	end
	local RPG_GUI = package.loaded["modules.rpg.gui"]
	local rpg_t = RPG.get("rpg_t")
	local rpg_extra = RPG.get("rpg_extra")
	if one_time_reset then
		local total = rpg_t[player.index].total
		if not total then
			total = 0
		end
		local old_level = rpg_t[player.index].level
		local old_points_to_distribute = rpg_t[player.index].points_to_distribute
		local old_xp = rpg_t[player.index].xp
		rpg_t[player.index] = {
			level = 1,
			xp = 0,
			strength = 10,
			magicka = 10,
			dexterity = 10,
			vitality = 10,
			mana = 0,
			mana_max = 0,
			last_spawned = 0,
			dropdown_select_index = 1,
			allocate_index = 1,
			flame_boots = false,
			enable_entity_spawn = false,
			health_bar = rpg_t[player.index].health_bar,
			mana_bar = rpg_t[player.index].mana_bar,
			points_to_distribute = 0,
			last_floaty_text = visuals_delay,
			xp_since_last_floaty_text = 0,
			reset = true,
			capped = false,
			bonus = rpg_extra.breached_walls or 1,
			rotated_entity_delay = 0,
			last_mined_entity_position = { x = 0, y = 0 },
			show_bars = false,
			stone_path = false,
			one_punch = false,
		}
		rpg_t[player.index].points_to_distribute = old_points_to_distribute + total
		rpg_t[player.index].xp = old_xp
		rpg_t[player.index].level = old_level
	else
		rpg_t[player.index] = {
			level = 1,
			xp = 0,
			strength = 10,
			magicka = 10,
			dexterity = 10,
			vitality = 10,
			mana = 0,
			mana_max = 0,
			last_spawned = 0,
			dropdown_select_index = 1,
			allocate_index = 1,
			flame_boots = false,
			enable_entity_spawn = false,
			points_to_distribute = 0,
			last_floaty_text = visuals_delay,
			xp_since_last_floaty_text = 0,
			reset = false,
			capped = false,
			total = 0,
			bonus = 1,
			rotated_entity_delay = 0,
			last_mined_entity_position = { x = 0, y = 0 },
			show_bars = false,
			stone_path = false,
			one_punch = false,
		}
	end
	RPG_GUI.draw_gui_char_button(player)
	RPG_GUI.draw_level_text(player)
	RPG_GUI.update_char_button(player)
	RPG_GUI.update_player_stats(player)
end

function Public.rpg_reset_all_players()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:562')
	local rpg_t = RPG.get("rpg_t")
	local rpg_extra = RPG.get("rpg_extra")
	for k, _ in pairs(rpg_t) do
		rpg_t[k] = nil
	end
	for _, p in pairs(game.connected_players) do
		Public.rpg_reset_player(p)
	end
	rpg_extra.breached_walls = 1
	rpg_extra.reward_new_players = 0
	rpg_extra.global_pool = 0
end

function Public.gain_xp(player, amount, added_to_pool, text)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:576')
	if not Public.validate_player(player) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:578')
		return
	end
	local rpg_extra = RPG.get("rpg_extra")
	local rpg_t = RPG.get("rpg_t")

	if Public.level_limit_exceeded(player) then
		add_to_global_pool(amount, false)
		if not rpg_t[player.index].capped then
			rpg_t[player.index].capped = true
			local message = { "rpg_functions.max_level" }
			Alert.alert_player_warning(player, 10, message)
		end
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:590')
		return
	end

	local text_to_draw

	if rpg_t[player.index].capped then
		rpg_t[player.index].capped = false
	end

	if not added_to_pool then
		RPG.debug_log("RPG - " .. player.name .. " got org xp: " .. amount)
		local fee = amount - add_to_global_pool(amount, true)
		RPG.debug_log("RPG - " .. player.name .. " got fee: " .. fee)
		amount = math.round(amount, 3) - fee
		if rpg_extra.difficulty then
			amount = amount + rpg_extra.difficulty
		end
		RPG.debug_log("RPG - " .. player.name .. " got after fee: " .. amount)
	else
		RPG.debug_log("RPG - " .. player.name .. " got org xp: " .. amount)
	end

	rpg_t[player.index].xp = rpg_t[player.index].xp + amount
	rpg_t[player.index].xp_since_last_floaty_text = rpg_t[player.index].xp_since_last_floaty_text + amount

	if not experience_levels[rpg_t[player.index].level + 1] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:616')
		return
	end

	if rpg_t[player.index].xp >= experience_levels[rpg_t[player.index].level + 1] then
		level_up(player)
	end

	if rpg_t[player.index].last_floaty_text > game.tick then
		if not text then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:625')
			return
		end
	end

	if text then
		text_to_draw = "+" .. math.floor(amount) .. " xp"
	else
		text_to_draw = "+" .. math.floor(rpg_t[player.index].xp_since_last_floaty_text) .. " xp"
	end

	player.create_local_flying_text({
		text = text_to_draw,
		position = player.position,
		color = xp_floating_text_color,
		time_to_live = 340,
		speed = 2,
	})

	rpg_t[player.index].xp_since_last_floaty_text = 0
	rpg_t[player.index].last_floaty_text = game.tick + visuals_delay
end

function Public.global_pool(players, count)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:647')
	local rpg_extra = RPG.get("rpg_extra")

	if not rpg_extra.global_pool then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:651')
		return
	end

	local pool = math.floor(rpg_extra.global_pool)

	local random_amount = math.random(5000, 10000)

	if pool <= random_amount then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:659')
		return
	end

	if pool >= 20000 then
		pool = 20000
	end

	local share = pool / count

	RPG.debug_log("RPG - Share per player:" .. share)

	for i = 1, #players do
		local p = players[i]
		if p.afk_time < 5000 then
			if not Public.level_limit_exceeded(p) then
				Public.gain_xp(p, share, false, true)
				Public.xp_effects(p)
			else
				share = share / 10
				rpg_extra.leftover_pool = rpg_extra.leftover_pool + share
				RPG.debug_log("RPG - player capped: " .. p.name .. ". Amount to pool:" .. share)
			end
		else
			local message = { "rpg_functions.pool_reward", p.name }
			Alert.alert_player_warning(p, 10, message)
			share = share / 10
			rpg_extra.leftover_pool = rpg_extra.leftover_pool + share
			RPG.debug_log("RPG - player AFK: " .. p.name .. ". Amount to pool:" .. share)
		end
	end

	rpg_extra.global_pool = rpg_extra.leftover_pool or 0

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:692')
	return
end

--- Distributes the global xp pool to every connected player.
function Public.distribute_pool()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:696')
	local count = #game.connected_players
	local players = game.connected_players
	Public.global_pool(players, count)
	print("Distributed the global XP pool")
end

Public.add_to_global_pool = add_to_global_pool

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/rpg/functions.lua:705')
return Public
