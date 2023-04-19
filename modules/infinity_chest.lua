local Event = require 'utils.event'
local Global = require 'utils.global'

local this = {
    inf_chests = {},
    inf_storage = {},
    inf_mode = {},
    inf_gui = {},
    storage = {},
    chest = {
        ['infinity-chest'] = 'infinity-chest'
    },
    stop = false,
    editor = {},
    limits = {},
    debug = false
}

local default_limit = 1000
local Public = {}

Public.storage = {}

Global.register(
    this,
    function(tbl)
        this = tbl
    end
)

function Public.get_table()
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:30')
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:31')
    return this
end

function Public.create_chest(surface, position, storage)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:34')
    local entity = surface.create_entity {name = 'infinity-chest', position = position, force = 'player'}
    this.inf_chests[entity.unit_number] = {entity = entity, storage = storage}
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:37')
    return entity
end

function Public.err_msg(string)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:40')
    local debug = this.debug
    if not debug then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:43')
        return
    end
    log('[Infinity] ' .. string)
end

local function has_value(tab)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:48')
    local count = 0
    for _, k in pairs(tab) do
        count = count + 1
    end
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:53')
    return count
end

local function return_value(tab)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:56')
    for index, value in pairs(tab) do
        if value then
            local temp
            temp = value
            tab[index] = nil
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:62')
            return temp
        end
    end
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:65')
    return false
end

local function validate_player(player)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:68')
    if not player then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:70')
        return false
    end
    if not player.valid then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:73')
        return false
    end
    if not player.character then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:76')
        return false
    end
    if not player.connected then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:79')
        return false
    end
    if not game.players[player.index] then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:82')
        return false
    end
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:84')
    return true
end

local function built_entity(event)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:87')
    local entity = event.created_entity
    if not entity.valid then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:90')
        return
    end
    if entity.name ~= this.chest[entity.name] then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:93')
        return
    end
    if event.player_index then
        local player = game.get_player(event.player_index)
        if this.storage[player.index] and has_value(this.storage[player.index].chests) then
            if this.stop then
                goto continue
            end
            local chest_index = this.storage[player.index].chests
            local limit_index = this.storage[player.index].limits
            this.inf_storage[entity.unit_number] = return_value(chest_index)
            this.limits[entity.unit_number] = return_value(limit_index)
        end
        ::continue::
        entity.active = false
        if not this.limits[entity.unit_number] then
            this.limits[entity.unit_number] = default_limit
        end
        this.inf_chests[entity.unit_number] = entity
        this.inf_mode[entity.unit_number] = 1
        rendering.draw_text {
            text = '♾',
            surface = entity.surface,
            target = entity,
            target_offset = {0, -0.6},
            scale = 2,
            color = {r = 0, g = 0.6, b = 1},
            alignment = 'center'
        }
    end
end

local function built_entity_robot(event)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:125')
    local entity = event.created_entity
    if not entity.valid then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:128')
        return
    end
    if entity.name ~= this.chest[entity.name] then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:131')
        return
    end
    entity.destroy()
end

local function item(item_name, item_count, inv, unit_number)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:136')
    local item_stack = game.item_prototypes[item_name].stack_size
    local diff = item_count - item_stack

    if not this.inf_storage[unit_number] then
        this.inf_storage[unit_number] = {}
    end
    local storage = this.inf_storage[unit_number]

    local mode = this.inf_mode[unit_number]
    if mode == 2 then
        diff = 2 ^ 31
    elseif mode == 4 then
        diff = 2 ^ 31
    end
    if diff > 0 then
        if not storage[item_name] then
            local count = inv.remove({name = item_name, count = diff})
            this.inf_storage[unit_number][item_name] = count
        else
            if this.inf_storage[unit_number][item_name] >= this.limits[unit_number] then
                Public.err_msg('Limit for entity: ' .. unit_number .. 'and item: ' .. item_name .. ' is limited. ')
                if mode == 1 then
                    this.inf_mode[unit_number] = 3
                end
                if inv.can_insert({name = item_name, count = item_stack}) then
                    local count = inv.insert({name = item_name, count = item_stack})
                    this.inf_storage[unit_number][item_name] = storage[item_name] - count
                end
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:165')
                return
            end
            local count = inv.remove({name = item_name, count = diff})
            this.inf_storage[unit_number][item_name] = storage[item_name] + count
        end
    elseif diff < 0 then
        if not storage[item_name] then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:172')
            return
        end
        if storage[item_name] > (diff * -1) then
            local inserted = inv.insert({name = item_name, count = (diff * -1)})
            this.inf_storage[unit_number][item_name] = storage[item_name] - inserted
        else
            inv.insert({name = item_name, count = storage[item_name]})
            this.inf_storage[unit_number][item_name] = nil
        end
    end
end

local function is_chest_empty(entity, player)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:184')
    local number = entity.unit_number
    local inv = this.inf_mode[number]

    if inv == 2 then
        for k, v in pairs(this.inf_storage) do
            if k == number then
                if not v then
                    goto no_storage
                end
                if (has_value(v) >= 1) then
                    this.storage[player].chests[number] = this.inf_storage[number]
                    this.storage[player].limits[number] = this.limits[number]
                end
            end
        end
        ::no_storage::

        this.inf_chests[number] = nil
        this.inf_storage[number] = nil
        this.limits[number] = nil
        this.inf_mode[number] = nil
    else
        this.inf_chests[number] = nil
        this.inf_storage[number] = nil
        this.limits[number] = nil
        this.inf_mode[number] = nil
    end
end

local function on_entity_died(event)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:214')
    local entity = event.entity
    if not entity then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:217')
        return
    end
    if entity.name ~= this.chest[entity.name] then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:220')
        return
    end
    local number = entity.unit_number
    this.inf_mode[number] = nil
    this.inf_chests[number] = nil
    this.inf_storage[number] = nil
    this.limits[number] = nil
end

local function on_pre_player_mined_item(event)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:229')
    local entity = event.entity
    local player = game.players[event.player_index]
    if not player then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:233')
        return
    end

    if not this.storage[player.index] then
        this.storage[player.index] = {
            chests = {},
            limits = {}
        }
    end

    if entity.name ~= this.chest[entity.name] then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:244')
        return
    end
    is_chest_empty(entity, player.index)
    local data = this.inf_gui[player.name]
    if not data then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:249')
        return
    end
    data.frame.destroy()
end

local function update_chest()
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:254')
    for unit_number, chest in pairs(this.inf_chests) do
        if not chest.valid then
            goto continue
        end
        local inv = chest.get_inventory(defines.inventory.chest)
        local content = inv.get_contents()

        local mode = this.inf_mode[chest.unit_number]
        if mode then
            if mode == 1 then
                inv.set_bar()
                chest.destructible = false
                chest.minable = false
            elseif mode == 2 then
                inv.set_bar(1)
                chest.destructible = true
                chest.minable = true
            elseif mode == 3 then
                inv.set_bar(2)
                chest.destructible = false
                chest.minable = false
            end
        end

        for item_name, item_count in pairs(content) do
            item(item_name, item_count, inv, unit_number)
        end

        local storage = this.inf_storage[unit_number]
        if not storage then
            goto continue
        end
        for item_name, _ in pairs(storage) do
            if storage[item_name] <= this.limits[unit_number] and mode == 3 then
                this.inf_mode[unit_number] = 1
            end
            if not content[item_name] then
                item(item_name, 0, inv, unit_number)
            end
        end

        ::continue::
    end
end

local function text_changed(event)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:300')
    local element = event.element
    if not element then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:303')
        return
    end
    if not element.valid then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:306')
        return
    end

    local player = game.players[event.player_index]

    local data = this.inf_gui[player.name]
    if not data then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:313')
        return
    end

    if not data.text_field or not data.text_field.valid then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:317')
        return
    end

    if not data.text_field.text then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:321')
        return
    end

    local value = tonumber(element.text)

    if not value then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:327')
        return
    end

    if value ~= '' and value >= default_limit then
        data.text_field.text = value

        local entity = data.entity
        if not entity or not entity.valid then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:335')
            return
        end

        local unit_number = entity.unit_number

        this.limits[unit_number] = value
    elseif value ~= '' and value <= default_limit then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:342')
        return
    end
    this.inf_gui[player.name].updated = false
end

local function gui_opened(event)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:347')
    if not event.gui_type == defines.gui_type.entity then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:349')
        return
    end
    local entity = event.entity
    if not entity then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:353')
        return
    end
    if not entity.valid or entity.name ~= this.chest[entity.name] then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:356')
        return
    end
    local player = game.players[event.player_index]
    local frame =
        player.gui.center.add {
        type = 'frame',
        caption = 'Unlimited Chest',
        direction = 'vertical',
        name = entity.unit_number
    }
    local controls = frame.add {type = 'flow', direction = 'horizontal'}
    local items = frame.add {type = 'flow', direction = 'vertical'}

    local mode = this.inf_mode[entity.unit_number]
    local selected = mode and mode or 1
    local tbl = controls.add {type = 'table', column_count = 1}

    local limit_tooltip =
        '[color=yellow]Limit Info:[/color]\nThis is only usable if you intend to use this chest for one item.'

    local mode_tooltip =
        '[color=yellow]Mode Info:[/color]\nEnabled: will active the chest and allow for insertions.\nDisabled: will deactivate the chest and let´s the player utilize the GUI to retrieve items.\nLimited: will deactivate the chest as per limit.'

    local btn =
        tbl.add {
        type = 'sprite-button',
        tooltip = '[color=blue]Info![/color]\nThis chest stores unlimited quantity of items (up to 48 different item types).\nThe chest is best used with an inserter to add / remove items.\nThe chest is mineable if state is disabled.\nContent is kept when mined.\n[color=yellow]Limit:[/color]\nThis is only usable if you intend to use this chest for one item.',
        sprite = 'utility/questionmark'
    }
    btn.style.height = 20
    btn.style.width = 20
    btn.enabled = false
    btn.focus()

    local tbl_2 = tbl.add {type = 'table', column_count = 4}

    tbl_2.add {type = 'label', caption = 'Mode: ', tooltip = mode_tooltip}
    local drop_down
    if player.admin and this.editor[player.name] then
        drop_down =
            tbl_2.add {
            type = 'drop-down',
            items = {'Enabled', 'Disabled', 'Limited', 'Editor'},
            selected_index = selected,
            name = entity.unit_number,
            tooltip = mode_tooltip
        }
    else
        drop_down =
            tbl_2.add {
            type = 'drop-down',
            items = {'Enabled', 'Disabled', 'Limited'},
            selected_index = selected,
            name = entity.unit_number,
            tooltip = mode_tooltip
        }
    end

    tbl_2.add({type = 'label', caption = ' Limit: ', tooltip = limit_tooltip})
    local text_field = tbl_2.add({type = 'textfield', text = this.limits[entity.unit_number]})
    text_field.style.width = 80
    text_field.numeric = true
    text_field.tooltip = limit_tooltip

    this.inf_mode[entity.unit_number] = drop_down.selected_index
    player.opened = frame
    this.inf_gui[player.name] = {
        item_frame = items,
        frame = frame,
        text_field = text_field,
        entity = entity,
        updated = false
    }
end

local function update_gui()
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:431')
    for _, player in pairs(game.connected_players) do
        local chest_gui_data = this.inf_gui[player.name]
        if not chest_gui_data then
            goto continue
        end
        local frame = chest_gui_data.item_frame
        local entity = chest_gui_data.entity
        if not frame then
            goto continue
        end
        if not entity or not entity.valid then
            goto continue
        end
        local mode = this.inf_mode[entity.unit_number]
        if (mode == 2 or mode == 3 or mode == 4) and this.inf_gui[player.name].updated then
            goto continue
        end
        frame.clear()

        local tbl = frame.add {type = 'table', column_count = 10, name = 'infinity_chest_inventory'}
        local total = 0
        local items = {}

        local storage = this.inf_storage[entity.unit_number]
        local inv = entity.get_inventory(defines.inventory.chest)
        local content = inv.get_contents()
        local limit = this.limits[entity.unit_number]
        local full

        if not storage then
            goto no_storage
        end
        for item_name, item_count in pairs(storage) do
            total = total + 1
            items[item_name] = item_count
            if storage[item_name] >= limit then
                full = true
            end
        end
        ::no_storage::

        if full then
            goto full
        end

        for item_name, item_count in pairs(content) do
            if not items[item_name] then
                total = total + 1
                items[item_name] = item_count
            else
                items[item_name] = items[item_name] + item_count
            end
        end

        ::full::

        local btn
        for item_name, item_count in pairs(items) do
            if mode == 1 or mode == 3 then
                btn =
                    tbl.add {
                    type = 'sprite-button',
                    sprite = 'item/' .. item_name,
                    style = 'slot_button',
                    number = item_count,
                    name = item_name,
                    tooltip = 'Withdrawal is possible when state is disabled!'
                }
                btn.enabled = false
            elseif mode == 2 or mode == 4 then
                btn =
                    tbl.add {
                    type = 'sprite-button',
                    sprite = 'item/' .. item_name,
                    style = 'slot_button',
                    number = item_count,
                    name = item_name
                }
                btn.enabled = true
            end
        end

        while total < 48 do
            local btns
            if mode == 1 or mode == 2 or mode == 3 then
                btns = tbl.add {type = 'sprite-button', style = 'slot_button'}
                btns.enabled = false
            elseif mode == 4 then
                btns = tbl.add {type = 'choose-elem-button', style = 'slot_button', elem_type = 'item'}
                btns.enabled = true
            end

            total = total + 1
        end

        this.inf_gui[player.name].updated = true
        ::continue::
    end
end

local function gui_closed(event)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:532')
    local player = game.players[event.player_index]
    local type = event.gui_type

    if type == defines.gui_type.custom then
        local data = this.inf_gui[player.name]
        if not data then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:539')
            return
        end
        data.frame.destroy()
        this.inf_gui[player.name] = nil
    end
end

local function state_changed(event)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:546')
    local element = event.element
    if not element.valid then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:549')
        return
    end
    if not element.selected_index then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:552')
        return
    end
    local unit_number = tonumber(element.name)
    if not unit_number then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:556')
        return
    end
    if not this.inf_mode[unit_number] then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:559')
        return
    end
    this.inf_mode[unit_number] = element.selected_index
    local mode = this.inf_mode[unit_number]
    if mode >= 2 then
        local player = game.players[event.player_index]
        if not validate_player(player) then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:566')
            return
        end
        this.inf_gui[player.name].updated = false
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:569')
        return
    end
end

local function gui_click(event)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:573')
    local element = event.element
    local player = game.players[event.player_index]
    if not validate_player(player) then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:577')
        return
    end
    if not element.valid then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:580')
        return
    end
    local parent = element.parent
    if not parent then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:584')
        return
    end
    if parent.name ~= 'infinity_chest_inventory' then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:587')
        return
    end
    local unit_number = tonumber(parent.parent.parent.name)
    if tonumber(element.name) == unit_number then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:591')
        return
    end

    local shift = event.shift
    local ctrl = event.control
    local name = element.name
    local storage = this.inf_storage[unit_number]
    local mode = this.inf_mode[unit_number]

    if not storage then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:601')
        return
    end

    if player.admin then
        if mode == 4 then
            if not storage[name] then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:607')
                return
            end
            if ctrl then
                storage[name] = storage[name] + 5000000
                goto update
            elseif shift then
                storage[name] = storage[name] - 5000000
                if storage[name] <= 0 then
                    storage[name] = nil
                end
                goto update
            end
        end
    end

    if mode == 1 then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:623')
        return
    end

    if ctrl then
        local count = storage[name]
        if not count then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:629')
            return
        end
        local inserted = player.insert {name = name, count = count}
        if not inserted then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:633')
            return
        end
        if inserted == count then
            storage[name] = nil
        else
            storage[name] = storage[name] - inserted
        end
    elseif shift then
        local count = storage[name]
        local stack = game.item_prototypes[name].stack_size
        if not count then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:644')
            return
        end
        if not stack then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:647')
            return
        end
        if count > stack then
            local inserted = player.insert {name = name, count = stack}
            storage[name] = storage[name] - inserted
        else
            player.insert {name = name, count = count}
            storage[name] = nil
        end
    else
        if not storage[name] then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:658')
            return
        end
        storage[name] = storage[name] - 1
        player.insert {name = name, count = 1}
        if storage[name] <= 0 then
            storage[name] = nil
        end
    end

    ::update::

    for _, p in pairs(game.connected_players) do
        if this.inf_gui[p.name] then
            this.inf_gui[p.name].updated = false
        end
    end
end

local function on_gui_elem_changed(event)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:676')
    local element = event.element
    local player = game.players[event.player_index]
    if not validate_player(player) then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:680')
        return
    end
    if not element.valid then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:683')
        return
    end
    local parent = element.parent
    if not parent then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:687')
        return
    end
    if parent.name ~= 'infinity_chest_inventory' then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:690')
        return
    end
    local unit_number = tonumber(parent.parent.parent.name)
    if tonumber(element.name) == unit_number then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:694')
        return
    end

    local button = event.button
    local storage = this.inf_storage[unit_number]
    if not storage then
        this.inf_storage[unit_number] = {}
        storage = this.inf_storage[unit_number]
    end
    local name = element.elem_value

    if button == defines.mouse_button_type.right then
        storage[name] = nil
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:707')
        return
    end

    if not name then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:711')
        return
    end
    storage[name] = 5000000

    if this.inf_gui[player.name] then
        this.inf_gui[player.name].updated = false
    end
end

local function on_entity_settings_pasted(event)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:720')
    local player = game.get_player(event.player_index)
    if not player or not player.valid then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:723')
        return
    end

    local source = event.source
    if not source or not source.valid then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:728')
        return
    end

    local destination = event.destination
    if not destination or not destination.valid then
log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:733')
        return
    end

    local source_number = source.unit_number
    local destination_number = destination.unit_number

    local source_limit = this.limits[source_number]

    this.limits[destination_number] = source_limit
end

local function tick()
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:744')
    update_chest()
    update_gui()
end

Event.add(defines.events.on_tick, tick)
Event.add(defines.events.on_gui_click, gui_click)
Event.add(defines.events.on_gui_opened, gui_opened)
Event.add(defines.events.on_gui_closed, gui_closed)
Event.add(defines.events.on_built_entity, built_entity)
Event.add(defines.events.on_robot_built_entity, built_entity_robot)
Event.add(defines.events.on_pre_player_mined_item, on_pre_player_mined_item)
Event.add(defines.events.on_gui_selection_state_changed, state_changed)
Event.add(defines.events.on_entity_died, on_entity_died)
Event.add(defines.events.on_gui_elem_changed, on_gui_elem_changed)
Event.add(defines.events.on_gui_text_changed, text_changed)
Event.add(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/modules/infinity_chest.lua:762')
return Public
