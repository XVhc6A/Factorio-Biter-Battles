local Global = require("utils.global")
local Event = require("utils.event")

local this = {}
local Public = {}

Global.register(this, function(tbl)
	this = tbl
end)

function Public.debug_module()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:10')
	this.next_wave = 1000
	this.wave_interval = 500
	this.wave_enforced = true
end

function Public.reset_wave_defense()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:16')
	this.boss_wave = false
	this.boss_wave_warning = false
	this.side_target_count = 0
	this.active_biters = {}
	this.active_biter_count = 0
	this.active_biter_threat = 0
	this.average_unit_group_size = 24
	this.biter_raffle = {}
	this.debug = false
	this.game_lost = false
	this.get_random_close_spawner_attempts = 5
	this.group_size = 2
	this.last_wave = game.tick
	this.max_active_biters = 1280
	this.max_active_unit_groups = 32
	this.max_biter_age = 3600 * 60
	this.nests = {}
	this.nest_building_density = 48
	this.next_wave = game.tick + 3600 * 15
	this.side_targets = {}
	this.simple_entity_shredding_cost_modifier = 0.009
	this.spawn_position = { x = 0, y = 64 }
	this.spitter_raffle = {}
	this.surface_index = 1
	this.target = nil
	this.threat = 0
	this.threat_gain_multiplier = 2
	this.threat_log = {}
	this.threat_log_index = 0
	this.unit_groups = {}
	this.unit_group_pos = {
		positions = {},
	}
	this.index = 0
	this.random_group = nil
	this.unit_group_command_delay = 3600 * 20
	this.unit_group_command_step_length = 15
	this.unit_group_last_command = {}
	this.wave_interval = 3600
	this.wave_enforced = false
	this.wave_number = 0
	this.worm_building_chance = 3
	this.worm_building_density = 16
	this.worm_raffle = {}
	this.clear_corpses = false
	this.biter_health_boost = 1
	this.alert_boss_wave = false
	this.remove_entities = false
	this.enable_side_target = false
	this.enable_threat_log = true
	this.disable_threat_below_zero = false
	this.check_collapse_position = true
	this.modified_boss_health = true
	this.resolve_pathing = true
	this.fill_tiles_so_biter_can_path = true
end

function Public.get(key)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:74')
	if key then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:76')
		return this[key]
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:78')
		return this
	end
end

function Public.set(key, value)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:82')
	if key and (value or value == false or value == "nil") then
		if value == "nil" then
			this[key] = nil
		else
			this[key] = value
		end
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:89')
		return this[key]
	elseif key then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:91')
		return this[key]
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:93')
		return this
	end
end

Public.get_table = Public.get

function Public.clear_corpses(value)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:99')
	if value or value == false then
		this.clear_corpses = value
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:103')
	return this.clear_corpses
end

function Public.get_wave()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:106')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:107')
	return this.wave_number
end

function Public.get_disable_threat_below_zero()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:110')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:111')
	return this.disable_threat_below_zero
end

function Public.set_disable_threat_below_zero(boolean)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:114')
	if boolean or boolean == false then
		this.disable_threat_below_zero = boolean
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:118')
	return this.disable_threat_below_zero
end

function Public.get_alert_boss_wave()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:121')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:122')
	return this.get_alert_boss_wave
end

function Public.alert_boss_wave(boolean)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:125')
	if boolean or boolean == false then
		this.alert_boss_wave = boolean
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:129')
	return this.alert_boss_wave
end

function Public.set_spawn_position(tbl)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:132')
	if type(tbl) == "table" then
		this.spawn_position = tbl
	else
		error("Tbl must be of type table.")
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:138')
	return this.spawn_position
end

function Public.remove_entities(boolean)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:141')
	if boolean or boolean == false then
		this.remove_entities = boolean
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:145')
	return this.remove_entities
end

function Public.enable_threat_log(boolean)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:148')
	if boolean or boolean == false then
		this.enable_threat_log = boolean
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:152')
	return this.enable_threat_log
end

function Public.check_collapse_position(boolean)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:155')
	if boolean or boolean == false then
		this.check_collapse_position = boolean
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:159')
	return this.check_collapse_position
end

function Public.enable_side_target(boolean)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:162')
	if boolean or boolean == false then
		this.enable_side_target = boolean
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:166')
	return this.enable_side_target
end

function Public.modified_boss_health(boolean)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:169')
	if boolean or boolean == false then
		this.modified_boss_health = boolean
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:173')
	return this.modified_boss_health
end

function Public.resolve_pathing(boolean)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:176')
	if boolean or boolean == false then
		this.resolve_pathing = boolean
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:180')
	return this.resolve_pathing
end

function Public.fill_tiles_so_biter_can_path(boolean)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:183')
	if boolean or boolean == false then
		this.fill_tiles_so_biter_can_path = boolean
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:187')
	return this.fill_tiles_so_biter_can_path
end

function Public.set_biter_health_boost(number)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:190')
	if number and type(number) == "number" then
		this.biter_health_boost = number
	else
		this.biter_health_boost = 1
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:196')
	return this.biter_health_boost
end

local on_init = function()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:199')
	Public.reset_wave_defense()
end

-- Event.on_nth_tick(30, Public.debug_module)

Event.on_init(on_init)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/wave_defense/table.lua:207')
return Public
