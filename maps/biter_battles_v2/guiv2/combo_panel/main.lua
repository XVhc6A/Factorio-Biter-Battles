local PlayerListTab = require("maps.biter_battles_v2.guiv2.combo_panel.playerlist")
local AdminTab = require("maps.biter_battles_v2.guiv2.combo_panel.admin")
local HistoryTab = require("maps.biter_battles_v2.guiv2.combo_panel.history")

local Public = {}


---@param tab_flow LuaGuiElement
---@param frame_flow LuaGuiElement
---@param prefix string
---@param handlers table<defines.events, table<string, function>>
---@return Guiv2ElementPair[]
function Public.add_tab_frame_and_handlers(tab_flow, frame_flow, prefix, handlers)
	local tabbed_pane_name = prefix .. "_tabbed_pane"
	local tabbed_pane = frame_flow.add({ type = "tabbed-pane", name = tabbed_pane_name })
	local toggle_button_name = prefix .. "_toggle_button"
	local toggle_button = tab_flow.add({
		type = "sprite-button",
		name = toggle_button_name,
		sprite = "item/raw-fish"
	})
	PlayerListTab.add_to_tabbed_pane(tabbed_pane, tabbed_pane_name .. "_playerlist")
	local player = game.get_player(tabbed_pane.player_index)
	-- TODO promoted?
	if player and player.admin then
		AdminTab.add_to_tabbed_pane(tabbed_pane, tabbed_pane_name .. "_admin", handlers)
	end
	HistoryTab.add_to_tabbed_pane(tabbed_pane, tabbed_pane_name .. "_histories", handlers)
	return {
		frame = tabbed_pane,
		tab = toggle_button,
	}
end

return Public
