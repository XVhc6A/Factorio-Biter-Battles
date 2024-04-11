local Public = {}

local POKES = {}

local Session = require "utils.datastore.session_data"
local Jailed = require "utils.datastore.jail_data"

---@return string
local function create_online_offline_header_string()
	local out_string_tbl = {
		"[color=0.1,0.7,0.1]",
		tostring(#game.connected_players),
		"[/color] Online / [color=0.7,0.1,0.1]",
		tostring(#game.players - #game.connected_players),
		"[/color] Offline",
	}
	return table.concat(out_string_tbl)
end


---@param ticks_played int
---@return string
local function get_rank_from_total_time_played(ticks_played)
	local minutes = ticks_played / 3600
	local ranks = {
		"item/burner-mining-drill",
		"item/burner-inserter",
		"item/stone-furnace",
		"item/light-armor",
		"item/steam-engine",
		"item/inserter",
		"item/transport-belt",
		"item/underground-belt",
		"item/splitter",
		"item/assembling-machine-1",
		"item/long-handed-inserter",
		"item/electronic-circuit",
		"item/electric-mining-drill",
		"item/dummy-steel-axe",
		"item/heavy-armor",
		"item/steel-furnace",
		"item/gun-turret",
		"item/fast-transport-belt",
		"item/fast-underground-belt",
		"item/fast-splitter",
		"item/assembling-machine-2",
		"item/fast-inserter",
		"item/radar",
		"item/filter-inserter",
		"item/defender-capsule",
		"item/pumpjack",
		"item/chemical-plant",
		"item/solar-panel",
		"item/advanced-circuit",
		"item/modular-armor",
		"item/accumulator",
		"item/construction-robot",
		"item/distractor-capsule",
		"item/stack-inserter",
		"item/electric-furnace",
		"item/express-transport-belt",
		"item/express-underground-belt",
		"item/express-splitter",
		"item/assembling-machine-3",
		"item/processing-unit",
		"item/power-armor",
		"item/logistic-robot",
		"item/laser-turret",
		"item/stack-filter-inserter",
		"item/destroyer-capsule",
		"item/power-armor-mk2",
		"item/flamethrower-turret",
		"item/beacon",
		"item/steam-turbine",
		"item/centrifuge",
		"item/nuclear-reactor",
		"item/cannon-shell",
		"item/rocket",
		"item/explosive-cannon-shell",
		"item/explosive-rocket",
		"item/uranium-cannon-shell",
		"item/explosive-uranium-cannon-shell",
		"item/atomic-bomb",
		"achievement/so-long-and-thanks-for-all-the-fish",
		"achievement/golem"
	}

	--60? ranks

	local time_needed = 240 -- in minutes between rank upgrades
	local rank_index = math.min(math.floor(minutes / time_needed) + 1, #ranks)
	return ranks[rank_index]
end

---@param name string
---@param jailed_table table<string, boolean>
---@param trusted_table table<string, boolean>
---@return string
local function get_standing_from_player_name(name, jailed_table, trusted_table)
	local standing
	if game.players[name].admin then
		standing = "[color=red]Admin[/color]"
	elseif jailed_table[name] then
		standing = "[color=orange]Jailed[/color]"
	elseif trusted_table[name] then
		standing = "[color=green]Trusted[/color]"
	else
		standing = "[color=yellow]Untrusted[/color]"
	end
	return standing
end

---@param ticks int
---@return string
local function get_formatted_playtime_from_ticks(ticks)
	local math_floor = math.floor
	local seconds = math_floor(ticks / 60)
	local minutes = math_floor(seconds / 60)
	local hours = math_floor(minutes / 60)
	local days = math_floor(hours / 24)

	minutes = minutes % 60
	hours = hours % 24

	if days >= 1 then
		return string.format("%d days %d hours", days, hours)
	elseif hours >= 1 then
		return string.format("%d hours %d minutes", hours, minutes)
	else
		return string.format("%d minutes", minutes)
	end
end


---@param tabbed_pane LuaGuiElement
---@param prefix string
---@return LuaGuiElement
function Public.create_playerlist_frame(tabbed_pane, prefix)
	local parent_frame = tabbed_pane.add({
		type = "frame"
	})

	local playerlist_scroll_pane = parent_frame.add({
		type = "scroll-pane",
		name = "scroll_pane",
		direction = "vertical",
		horizontal_scroll_policy = "never",
		vertical_scroll_policy = "auto"
	})
	playerlist_scroll_pane.style.maximal_height = 530

	local frame = playerlist_scroll_pane.add({
		type = "frame",
		name = "left_main_tabbed_gui_playerlist_frame",
		direction = "vertical",
	})
	frame.style.padding = 8
	local trusted_table = Session.get_trusted_table()
	local jailed_table = Jailed.get_jailed_table()

	---@type TabbedPanelPlayersTableColumn[]
	local table_spec = {
		{
			header_id = prefix .. "_rank_header",
			header_text = "Rank",
			column_width = 60,
		},
		{
			header_id = prefix .. "_player_header",
			header_text = create_online_offline_header_string(),
			column_width = 160,
		},
		{
			header_id = prefix .. "_standing_header",
			header_text = "Standing",
			column_width = 80,
		},
		{
			header_id = prefix .. "_total_time_header",
			header_text = "Total Time",
			column_width = 180,
		},
		{
			header_id = prefix .. "_current_time_header",
			header_text = "Current Time",
			column_width = 180,
		},
		{
			header_id = prefix .. "_poke_header",
			header_text = "Poke",
			column_width = 40,
		},
	}
	local playerlist_table = frame.add({ type = "table", name = "player_list_panel_table", column_count = #table_spec })

	-- Header
	for _, v in ipairs(table_spec) do
		local header_label = playerlist_table.add({
			type = "label",
			name = v.header_id,
			caption = v.header_text
		})
		header_label.style.font = "default-bold"
		header_label.style.font_color = { r = 0.98, g = 0.66, b = 0.22 }
		header_label.style.minimal_width = v.column_width
		header_label.style.maximal_width = v.column_width
	end

	-- local player_list = get_sorted_list(sort_by)
	---@type TabbedPanelPlayerStatsRow[]
	local player_stats_rows = {}
	for i, player in pairs(game.connected_players) do
		-- table.insert(player_stats_rows, )
		local total_played_time_ticks = global.total_time_online_players[player.name]
		if total_played_time_ticks == nil then
			total_played_time_ticks = 0
		end
		local maybe_pokes = POKES[player.name]
		if maybe_pokes == nil then
			maybe_pokes = 0
		end
		---@type TabbedPanelPlayerStatsRow
		local row = {
			name = player.name,
			index = player.index,
			rank = get_rank_from_total_time_played(total_played_time_ticks),
			total_played_time_ticks = total_played_time_ticks,
			total_played_time_str = get_formatted_playtime_from_ticks(total_played_time_ticks),
			current_played_time_ticks = player.online_time,
			current_played_time_str = get_formatted_playtime_from_ticks(player.online_time),
			pokes = maybe_pokes,
			standing = get_standing_from_player_name(player.name, jailed_table, trusted_table),
		}
		table.insert(player_stats_rows, row)
	end
	table.sort(
		player_stats_rows,
		function (a, b)
			return a.name < b.name
		end
	)

	local row_data = player_stats_rows[1]
	for i = 1, 21 do
		-- for _, row_data in ipairs(player_stats_rows) do
		row_data.index = i
		local sprite = playerlist_table.add({
			type = "sprite",
			name = "player_rankxxx_" .. row_data.index,
			sprite = row_data.rank
		})
		sprite.style.height = 32
		sprite.style.width = 32
		sprite.style.stretch_image_to_widget_size = true
		playerlist_table.add({
			type = "label",
			caption = row_data.name,
			name = "player_namexxx_" .. row_data.index,
		})
		playerlist_table.add({
			type = "label",
			caption = row_data.standing,
			name = "player_standingxxx_" .. row_data.index,
		})
		playerlist_table.add({
			type = "label",
			caption = row_data.total_played_time_str,
			name = "total_time_playedxxx_" .. row_data.index,
		})
		playerlist_table.add({
			type = "label",
			caption = row_data.current_played_time_str,
			name = "current_time_playedxxx_" .. row_data.index,
		})
		playerlist_table.add({
			type = "label",
			caption = row_data.pokes,
			name = "pokesxxx_" .. row_data.index,
		})
	end
	return parent_frame
end

---@param tabbed_pane LuaGuiElement
---@param prefix string
function Public.add_to_tabbed_pane(tabbed_pane, prefix)
	local frame = Public.create_playerlist_frame(tabbed_pane, prefix)
	local tab = tabbed_pane.add({ type = "tab", caption = "Players" })
	tabbed_pane.add_tab(tab, frame)
end

return Public
