local Public = {}
local Jailed = require "utils.datastore.jail_data"


local function admin_only_message(str)
	for _, player in pairs(game.connected_players) do
		if player.admin == true then
			player.print("Admins-only-message: " .. str, { r = 0.88, g = 0.88, b = 0.88 })
		end
	end
end



---@param parent LuaGuiElement
---@param prefix string
---@return LuaGuiElement
local function add_select_player_dropdown(parent, prefix)
	local player_names = {}
	for _, p in pairs(game.connected_players) do
		table.insert(player_names, tostring(p.name))
	end
	table.insert(player_names, "Select Player")

	local drop_down = parent.add({
		type = "drop-down",
		name = prefix .. "_player_select",
		items = player_names,
		selected_index = #player_names
	})
	drop_down.style.minimal_width = 326
	drop_down.style.right_padding = 12
	drop_down.style.left_padding = 12
	return drop_down
end


---@class AdminTaskButtonDefinition
---@field type string
---@field caption string
---@field name string
---@field tooltip string
---@field handler function


---@param admin_player_index int
---@param selected_player_dropdown LuaGuiElement
---@param prefix string
---@return AdminTaskButtonDefinition
local function admin_jail_task_definition(admin_player_index, selected_player_dropdown, prefix)
	return {
		type = "button",
		caption = "Jail",
		name = prefix .. "_jail",
		tooltip = "Jails the player, they will no longer be able to perform any actions except writing in chat.",
		handler = function ()
			local admin_player = game.get_player(admin_player_index)
			local target_player = game.get_player(selected_player_dropdown.selected_index)
			if admin_player and target_player then
				if admin_player.name ~= target_player.name then
					Jailed.try_ul_data(target_player.name, true, admin_player.name)
				else
					admin_player.print("You can't jail yourself!", { r = 1, g = 0.5, b = 0.1 })
				end
			end
		end
	}
end

---@param admin_player_index int
---@param selected_player_dropdown LuaGuiElement
---@param prefix string
---@return AdminTaskButtonDefinition
local function admin_free_task_definition(admin_player_index, selected_player_dropdown, prefix)
	return {
		type = "button",
		caption = "Free",
		name = prefix .. "_free",
		tooltip = "Frees the player from jail.",
		handler = function ()
			local admin_player = game.get_player(admin_player_index)
			local target_player = game.get_player(selected_player_dropdown.selected_index)
			if admin_player and target_player then
				if admin_player.name ~= target_player.name then
					Jailed.try_ul_data(target_player.name, false, admin_player.name)
				else
					admin_player.print("You can't free yourself!", { r = 1, g = 0.5, b = 0.1 })
				end
			end
		end
	}
end

---@param admin_player_index int
---@param selected_player_dropdown LuaGuiElement
---@param prefix string
---@return AdminTaskButtonDefinition
local function admin_bring_player_task_definition(admin_player_index, selected_player_dropdown, prefix)
	local bring_player_messages = {
		"Come here my friend!",
		"Papers, please.",
		"What are you up to?"
	}
	return {
		type = "button",
		caption = "Bring Player",
		name = prefix .. "_bring_player",
		tooltip = "Teleports the selected player to your position.",
		handler = function ()
			local admin_player = game.get_player(admin_player_index)
			local target_player = game.get_player(selected_player_dropdown.selected_index)
			if admin_player and target_player then
				if admin_player.name ~= target_player.name then
					if target_player.driving then
						admin_player.print(
							"Target player is in a vehicle, teleport not available.",
							{ r = 0.88, g = 0.88, b = 0.88 }
						)
					else
						local pos = admin_player.surface.find_non_colliding_position(
							"character",
							admin_player.position,
							50,
							1
						)
						if pos then
							target_player.teleport(pos, admin_player.surface)
							game.print(
								target_player.name ..
								" has been teleported to " ..
								admin_player.name ..
								". " .. bring_player_messages[math.random(1, #bring_player_messages)],
								{ r = 0.98, g = 0.66, b = 0.22 }
							)
						end
					end
					Jailed.try_ul_data(admin_player.name, false, target_player.name)
				else
					admin_player.print("You can't teleport yourself to yourself!", { r = 1, g = 0.5, b = 0.1 })
				end
			end
		end
	}
end

---@param admin_player_index int
---@param selected_player_dropdown LuaGuiElement
---@param prefix string
---@return AdminTaskButtonDefinition
local function admin_make_enemy_task_definition(admin_player_index, selected_player_dropdown, prefix)
	local enemy_messages = {
		"Shoot on sight!",
		"Wanted dead or alive!"
	}
	return {
		type = "button",
		caption = "Make Enemy",
		name = prefix .. "_enemy",
		tooltip = "Sets the selected players force to enemy_players. DO NOT USE IN PVP MAPS!!",
		handler = function ()
			local admin_player = game.get_player(admin_player_index)
			local target_player = game.get_player(selected_player_dropdown.selected_index)
			if admin_player and target_player then
				if admin_player.name ~= target_player.name then
					if not game.forces.enemy_players then
						game.create_force("enemy_players")
					end
					target_player.force = game.forces.enemy_players
					game.print(
						target_player.name .. " is now an enemy! " .. enemy_messages
						[math.random(1, #enemy_messages)],
						{ r = 0.95, g = 0.15, b = 0.15 }
					)
					admin_only_message(admin_player.name .. " has turned " .. target_player.name .. " into an enemy")
				else
					admin_player.print("You can't turn yourself yourself into an enemy!", { r = 1, g = 0.5, b = 0.1 })
				end
			end
		end
	}
end

---@param admin_player_index int
---@param selected_player_dropdown LuaGuiElement
---@param prefix string
---@return AdminTaskButtonDefinition
local function admin_make_ally_task_definition(admin_player_index, selected_player_dropdown, prefix)
	return {
		type = "button",
		caption = "Make Ally",
		name = prefix .. "_ally",
		tooltip = "Sets the selected players force back to the default player force. DO NOT USE IN PVP MAPS!!",
		handler = function ()
			local admin_player = game.get_player(admin_player_index)
			local target_player = game.get_player(selected_player_dropdown.selected_index)
			if admin_player and target_player then
				if admin_player.name ~= target_player.name then
					target_player.force = game.forces.player
					game.print(target_player.name .. " is our ally again!", { r = 0.98, g = 0.66, b = 0.1 }
					)
					admin_only_message(admin_player.name .. " made " .. target_player.name .. " our ally")
				else
					admin_player.print("You can't turn yourself yourself into an ally!", { r = 1, g = 0.5, b = 0.1 })
				end
			end
		end
	}
end

---@param admin_player_index int
---@param selected_player_dropdown LuaGuiElement
---@param prefix string
---@return AdminTaskButtonDefinition
local function admin_go_to_player_task_definition(admin_player_index, selected_player_dropdown, prefix)
	local go_to_player_messages = {
		"Papers, please.",
		"What are you up to?"
	}
	return {
		type = "button",
		caption = "Go to Player",
		name = prefix .. "_go_to_player",
		tooltip = "Teleport yourself to the selected player.",
		handler = function ()
			local admin_player = game.get_player(admin_player_index)
			local target_player = game.get_player(selected_player_dropdown.selected_index)
			if admin_player and target_player then
				if admin_player.name ~= target_player.name then
					if admin_player.driving then
						admin_player.print(
							"You are in a vehicle, teleport not available.",
							{ r = 0.88, g = 0.88, b = 0.88 }
						)
					else
						local pos = target_player.surface.find_non_colliding_position(
							"character",
							target_player.position,
							50,
							1
						)
						if pos then
							admin_player.teleport(pos, admin_player.surface)
							game.print(
								admin_player.name ..
								" is visiting " ..
								target_player.name ..
								". " .. go_to_player_messages[math.random(1, #go_to_player_messages)],
								{ r = 0.98, g = 0.66, b = 0.22 }
							)
						end
					end
					Jailed.try_ul_data(admin_player.name, false, target_player.name)
				else
					admin_player.print("You can't teleport yourself to yourself!", { r = 1, g = 0.5, b = 0.1 })
				end
			end
		end
	}
end

---@param admin_player_index int
---@param selected_player_dropdown LuaGuiElement
---@param prefix string
---@return AdminTaskButtonDefinition
local function admin_spank_task_definition(admin_player_index, selected_player_dropdown, prefix)
	return {
		type = "button",
		caption = "Spank",
		name = prefix .. "_spank",
		tooltip = "Hurts the selected player with minor damage. Can not kill the player.",
		handler = function ()
			local admin_player = game.get_player(admin_player_index)
			local target_player = game.get_player(selected_player_dropdown.selected_index)
			if admin_player and target_player then
				if admin_player.name ~= target_player.name then
					if target_player.character.health > 1 then
						target_player.character.damage(1, "player")
					end
					target_player.character.health = target_player.character.health - 5
					target_player.surface.create_entity({ name = "water-splash", position = target_player.position })
					game.print(admin_player.name .. " spanked " .. target_player.name,
						{ r = 0.98, g = 0.66, b = 0.22 })
				else
					admin_player.print(
						"You can't spank yourself, ask someone else to do it for you!",
						{ r = 1, g = 0.5, b = 0.1 }
					)
				end
			end
		end
	}
end


---@param admin_player_index int
---@param selected_player_dropdown LuaGuiElement
---@param prefix string
---@return AdminTaskButtonDefinition
local function admin_damage_task_definition(admin_player_index, selected_player_dropdown, prefix)
	local damage_messages = {
		" received a love letter from ",
		" received a strange package from "
	}
	return {
		type = "button",
		caption = "Damage",
		name = prefix .. "_damage",
		tooltip = "Damages the selected player with greater damage. Can not kill the player.",
		handler = function ()
			local admin_player = game.get_player(admin_player_index)
			local target_player = game.get_player(selected_player_dropdown.selected_index)
			if admin_player and target_player then
				if admin_player.name ~= target_player.name then
					if target_player.character.health > 1 then
						target_player.character.damage(1, "player")
					end
					target_player.character.health = target_player.character.health - 125
					target_player.surface.create_entity({ name = "big-explosion", position = target_player.position })
					game.print(
						target_player.name .. damage_messages[math.random(1, #damage_messages)] .. admin_player.name,
						{ r = 0.98, g = 0.66, b = 0.22 }
					)
				else
					admin_player.print(
						"You can't hurt yourself! Your cat needs you!",
						{ r = 1, g = 0.5, b = 0.1 }
					)
				end
			end
		end
	}
end

---@param admin_player_index int
---@param selected_player_dropdown LuaGuiElement
---@param prefix string
---@return AdminTaskButtonDefinition
local function admin_kill_task_definition(admin_player_index, selected_player_dropdown, prefix)
	local kill_messages = {
		" did not obey the law.",
		" should not have triggered the admins.",
		" did not respect authority.",
		" had a strange accident.",
		" was struck by lightning."
	}

	return {
		type = "button",
		caption = "Kill",
		name = prefix .. "_kill",
		tooltip = "Kills the selected player instantly.",
		handler = function ()
			local admin_player = game.get_player(admin_player_index)
			local target_player = game.get_player(selected_player_dropdown.selected_index)
			if admin_player and target_player then
				if admin_player.name ~= target_player.name then
					target_player.character.die("player")
					game.print(
						target_player.name .. kill_messages[math.random(1, #kill_messages)],
						{ r = 0.98, g = 0.66, b = 0.22 }
					)
					admin_only_message(admin_player.name .. " killed " .. target_player.name)
				else
					admin_player.print(
						"You can't kill yourself! Your betta fish needs you!",
						{ r = 1, g = 0.5, b = 0.1 }
					)
				end
			end
		end
	}
end

---@param parent LuaGuiElement
---@param prefix string
---@param selected_player_dropdown LuaGuiElement
---@param handlers table<string, function>
---@return LuaGuiElement
local function add_admin_task_buttons(parent, prefix, selected_player_dropdown, handlers)
	local t = parent.add({ type = "table", column_count = 3 })

	local parent_player_index = parent.player_index

	---@type AdminTaskButtonDefinition[]
	local buttons = {
		admin_jail_task_definition(parent_player_index, selected_player_dropdown, prefix),
		admin_free_task_definition(parent_player_index, selected_player_dropdown, prefix),
		admin_bring_player_task_definition(parent_player_index, selected_player_dropdown, prefix),
		admin_make_enemy_task_definition(parent_player_index, selected_player_dropdown, prefix),
		admin_make_ally_task_definition(parent_player_index, selected_player_dropdown, prefix),
		admin_go_to_player_task_definition(parent_player_index, selected_player_dropdown, prefix),
		admin_spank_task_definition(parent_player_index, selected_player_dropdown, prefix),
		admin_damage_task_definition(parent_player_index, selected_player_dropdown, prefix),
		admin_kill_task_definition(parent_player_index, selected_player_dropdown, prefix),
	}
	for _, button_params in pairs(buttons) do
		local button = t.add({
			type = button_params.type,
			name = button_params.name,
			caption = button_params.caption,
			tooltip = button_params.tooltip,
		})
		button.style.font = "default-bold"
		button.style.font_color = { r = 0.99, g = 0.99, b = 0.99 }
		button.style.minimal_width = 106
		handlers[button_params.name] = button_params.handler
	end
	return t
end


---@param admin_player_index int
---@param prefix string
---@return AdminTaskButtonDefinition
local function admin_turn_off_global_speakers_global_task_definition(admin_player_index, prefix)
	return {

		type = "button",
		caption = "Destroy global speakers",
		name = prefix .. "_turn_off_global_speakers",
		tooltip = "Destroys all speakers that are set to play sounds globally.",
		handler = function ()
			local counter = 0
			for _, surface in pairs(game.surfaces) do
				if surface.name ~= "gulag" then
					local speakers = surface.find_entities_filtered({ name = "programmable-speaker" })
					for _, speaker in pairs(speakers) do
						if speaker.parameters.playback_globally == true then
							speaker.surface.create_entity({ name = "massive-explosion", position = speaker.position })
							speaker.die("player")
							counter = counter + 1
						end
					end
				end
			end
			local admin_player = game.get_player(admin_player_index)
			if admin_player and counter ~= 0 then
				game.print(
					admin_player.name .. " has nuked " .. counter .. " global speaker(s).",
					{ r = 0.98, g = 0.66, b = 0.22 }
				)
			end
		end
	}
end

---@param admin_player_index int
---@param prefix string
---@return AdminTaskButtonDefinition
local function admin_delete_all_ghosts(admin_player_index, prefix)
	return {

		type = "button",
		caption = "Delete all ghosts",
		name = prefix .. "_delete_all_ghosts",
		tooltip = "Deletes all ghosts placed on all surfaces.",
		handler = function ()
			local counter = 0
			for _, surface in pairs(game.surfaces) do
				for _, ghost in pairs(surface.find_entities_filtered({ type = { "entity-ghost", "tile-ghost" } })) do
					ghost.destroy()
					counter = counter + 1
				end
			end
			if counter ~= 0 then
				local admin_player = game.get_player(admin_player_index)
				if admin_player then
					game.print(counter .. " blueprint(s) have been cleared!", { r = 0.98, g = 0.66, b = 0.22 })
					admin_only_message(admin_player.name .. " has cleared all blueprints.")
				end
			end
		end

	}
end
-- handler = function ()
-- 	local counter = 0
-- 	for _, surface in pairs(game.surfaces) do
-- 		if surface.name ~= "gulag" then
-- 			local speakers = surface.find_entities_filtered({ name = "programmable-speaker" })
-- 			for _, speaker in pairs(speakers) do
-- 				if speaker.parameters.playback_globally == true then
-- 					speaker.surface.create_entity({ name = "massive-explosion", position = speaker.position })
-- 					speaker.die("player")
-- 					counter = counter + 1
-- 				end
-- 			end
-- 		end
-- 	end
-- 	local admin_player = game.get_player(admin_player_index)
-- 	if admin_player and counter ~= 0 then
-- 		game.print(
-- 			admin_player.name .. " has nuked " .. counter .. " global speaker(s).",
-- 			{ r = 0.98, g = 0.66, b = 0.22 }
-- 		)
-- 	end
-- end


---@param parent LuaGuiElement
---@param prefix string
---@param handlers table<string, function>
---@return LuaGuiElement
local function add_admin_global_task_buttons(parent, prefix, handlers)
	parent.add({ type = "label", caption = "Global Actions:" })
	local t = parent.add({ type = "table", column_count = 2 })

	local parent_player_index = parent.player_index

	---@type AdminTaskButtonDefinition[]
	local buttons = {
		admin_turn_off_global_speakers_global_task_definition(parent_player_index, prefix),
		admin_delete_all_ghosts(parent_player_index, prefix)
	}

	for _, admin_task_definition in pairs(buttons) do
		local button = t.add({
			type = admin_task_definition.type,
			name = admin_task_definition.name,
			caption = admin_task_definition.caption,
			tooltip = admin_task_definition.tooltip,
		})
		button.style.font = "default-bold"
		button.style.font_color = { r = 0.45, g = 0.1, b = 0.1 }
		button.style.minimal_width = 106
		handlers[admin_task_definition.name] = admin_task_definition.handler
	end

	local line = parent.add({ type = "line" })
	line.style.top_margin = 8
	line.style.bottom_margin = 8
	return t
end

---@param tabbed_pane LuaGuiElement
---@param prefix string
---@return LuaGuiElement
function Public.create_admin_frame(tabbed_pane, prefix, handlers)
	local parent = tabbed_pane.add({ type = "frame", direction = "vertical" })
	local select_player_dropdown = add_select_player_dropdown(parent, prefix)
	local line1 = parent.add({ type = "line" })
	line1.style.top_margin = 8
	line1.style.bottom_margin = 8
	local admin_task_table = add_admin_task_buttons(parent, prefix, select_player_dropdown, handlers)
	local line2 = parent.add({ type = "line" })
	line2.style.top_margin = 8
	line2.style.bottom_margin = 8
	add_admin_global_task_buttons(parent, prefix, handlers)
	return parent
end

---@param tabbed_pane LuaGuiElement
---@param handlers table<string, function>
---@param prefix string
function Public.add_to_tabbed_pane(tabbed_pane, prefix, handlers)
	local frame = Public.create_admin_frame(tabbed_pane, prefix, handlers)
	local tab = tabbed_pane.add({ type = "tab", caption = "Admin" })
	tabbed_pane.add_tab(tab, frame)
end

return Public
