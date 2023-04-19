local function toggle(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:0')
	if not player.gui.top.global_chat_toggle then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:2')
		return
	end

	local button = player.gui.top.global_chat_toggle

	if button.caption == "Global Chat" then
		button.caption = "Team Chat"
		button.tooltip = "Chat messages are only sent to your team."
		button.style.font_color = { r = 0.77, g = 0.77, b = 0.0 }
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:11')
		return
	end

	button.caption = "Global Chat"
	button.tooltip = "Chat messages are sent to everyone."
	button.style.font_color = { r = 0.0, g = 0.77, b = 0.0 }
end

local function create_gui_button(player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:19')
	if player.gui.top.global_chat_toggle then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:21')
		return
	end
	local b = player.gui.top.add({
		type = "sprite-button",
		name = "global_chat_toggle",
		caption = "",
	})
	b.style.font = "heading-2"
	b.style.minimal_width = 100
	b.style.minimal_height = 38
	b.style.maximal_height = 38
	b.style.padding = 1
	b.style.margin = 0
	toggle(player)
end

local function on_player_joined_game(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:37')
	local player = game.players[event.player_index]
	create_gui_button(player)
end

local function on_gui_click(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:42')
	if not event then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:44')
		return
	end
	if not event.element then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:47')
		return
	end
	if not event.element.valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:50')
		return
	end
	local player = game.players[event.element.player_index]
	if event.element.name ~= "global_chat_toggle" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:54')
		return
	end
	toggle(player)
end

local function on_console_chat(event)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:59')
	if not event.message then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:61')
		return
	end
	if not event.player_index then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:64')
		return
	end
	local player = game.players[event.player_index]
	if not player.gui.top.global_chat_toggle then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:68')
		return
	end
	local button = player.gui.top.global_chat_toggle
	if button.caption ~= "Global Chat" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/global_chat_toggle.lua:72')
		return
	end
	for _, force in pairs(game.forces) do
		if force.name ~= player.force.name then
			force.print(player.name .. " " .. player.tag .. ": " .. event.message, player.chat_color)
		end
	end
end

local Event = require("utils.event")
Event.on_init(on_init)
Event.add(defines.events.on_console_chat, on_console_chat)
Event.add(defines.events.on_player_joined_game, on_player_joined_game)
Event.add(defines.events.on_gui_click, on_gui_click)
