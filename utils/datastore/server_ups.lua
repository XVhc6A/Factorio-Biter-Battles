local Server = require("utils.server")
local GUI = require("utils.gui")
local Event = require("utils.event")
local Color = require("utils.color_presets")

local ups_label = GUI.uid_name()

local function validate_player(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/server_ups.lua:7')
	if not player then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/server_ups.lua:9')
		return false
	end
	if not player.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/server_ups.lua:12')
		return false
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/server_ups.lua:14')
	return true
end

local function set_location(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/server_ups.lua:17')
	local gui = player.gui
	local label = gui.screen[ups_label]
	if not label or not label.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/server_ups.lua:21')
		return
	end
	local res = player.display_resolution
	local uis = player.display_scale
	label.location = { x = res.width - 423 * uis, y = 30 * uis }
end

local function create_label(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/server_ups.lua:28')
	local ups = Server.get_ups()
	local sUPS = "SUPS = " .. ups

	local label = player.gui.screen.add({
		type = "label",
		name = ups_label,
		caption = sUPS,
	})
	local style = label.style
	style.font = "default-game"
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/server_ups.lua:39')
	return label
end

Event.add(defines.events.on_player_joined_game, function(event)
	local player = game.get_player(event.player_index)

	local label = player.gui.screen[ups_label]

	if not label or not label.valid then
		label = create_label(player)
	end
	set_location(player)
	label.visible = false
end)
-- no wrapper
-- Update the value each second
--Event.on_nth_tick(
--    60,
--    function()
--        local ups = Server.get_ups()
--        local caption = 'SUPS = ' .. ups
--        local players = game.connected_players
--        for i = 1, #players do
--            local player = players[i]
--            local label = player.gui.screen[ups_label]
--            if label and label.valid then
--                label.caption = caption
--                set_location(player)
--            end
--        end
--    end
--)

commands.add_command("server-ups", "Toggle the server UPS display!", function()
	local player = game.player

	local secs = Server.get_current_time()

	if validate_player(player) then
		if not secs then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/datastore/server_ups.lua:79')
			return player.print("Not running on Comfy backend.", Color.warning)
		end

		local label = player.gui.screen[ups_label]
		if not label or not label.valid then
			label = create_label(player)
		end

		if label.visible then
			label.visible = false
			player.print("Removed Server-UPS label.", Color.warning)
		else
			label.visible = true
			set_location(player)
			player.print("Added Server-UPS label.", Color.success)
		end
	end
end)

Event.add(defines.events.on_player_display_resolution_changed, function(event)
	local player = game.get_player(event.player_index)
	set_location(player)
end)

Event.add(defines.events.on_player_display_scale_changed, function(event)
	local player = game.get_player(event.player_index)
	set_location(player)
end)
