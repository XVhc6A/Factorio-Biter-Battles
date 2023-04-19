local Gui = require("utils.gui")
local table = require("utils.table")

local gui_names = Gui.names
local type = type
local concat = table.concat
local inspect = table.inspect
local pcall = pcall
local loadstring = loadstring
local rawset = rawset

local Public = {}

local luaObject = { "{", nil, ", name = '", nil, "'}" }
local luaPlayer = { "{LuaPlayer, name = '", nil, "', index = ", nil, "}" }
local luaEntity = { "{LuaEntity, name = '", nil, "', unit_number = ", nil, "}" }
local luaGuiElement = { "{LuaGuiElement, name = '", nil, "'}" }

local function get(obj, prop)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:18')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:19')
	return obj[prop]
end

local function get_name_safe(obj)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:22')
	local s, r = pcall(get, obj, "name")
	if not s then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:25')
		return "nil"
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:27')
		return r or "nil"
	end
end

local function get_lua_object_type_safe(obj)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:31')
	local s, r = pcall(get, obj, "help")

	if not s then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:35')
		return
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:38')
	return r():match("Lua%a+")
end

local function inspect_process(item)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:41')
	if type(item) ~= "table" or type(item.__self) ~= "userdata" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:43')
		return item
	end

	local suc, valid = pcall(get, item, "valid")
	if not suc then
		-- no 'valid' property
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:49')
		return get_lua_object_type_safe(item) or "{NoHelp LuaObject}"
	end

	if not valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:53')
		return "{Invalid LuaObject}"
	end

	local obj_type = get_lua_object_type_safe(item)
	if not obj_type then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:58')
		return "{NoHelp LuaObject}"
	end

	if obj_type == "LuaPlayer" then
		luaPlayer[2] = item.name or "nil"
		luaPlayer[4] = item.index or "nil"

		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:65')
		return concat(luaPlayer)
	elseif obj_type == "LuaEntity" then
		luaEntity[2] = item.name or "nil"
		luaEntity[4] = item.unit_number or "nil"

		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:70')
		return concat(luaEntity)
	elseif obj_type == "LuaGuiElement" then
		local name = item.name
		luaGuiElement[2] = gui_names and gui_names[name] or name or "nil"

		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:75')
		return concat(luaGuiElement)
	else
		luaObject[2] = obj_type
		luaObject[4] = get_name_safe(item)

		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:80')
		return concat(luaObject)
	end
end

local inspect_options = { process = inspect_process }
function Public.dump(data)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:85')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:86')
	return inspect(data, inspect_options)
end
local dump = Public.dump

function Public.dump_ignore_builder(ignore)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:90')
	local function process(item)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:91')
		if ignore[item] then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:93')
			return nil
		end

		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:96')
		return inspect_process(item)
	end

	local options = { process = process }
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:100')
	return function(data)
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:101')
		return inspect(data, options)
	end
end

function Public.dump_function(func)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:105')
	local res = { "upvalues:\n" }

	local i = 1
	while true do
		local n, v = debug.getupvalue(func, i)

		if n == nil then
			break
		elseif n ~= "_ENV" then
			res[#res + 1] = n
			res[#res + 1] = " = "
			res[#res + 1] = dump(v)
			res[#res + 1] = "\n"
		end

		i = i + 1
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:124')
	return concat(res)
end

function Public.dump_text(text, player)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:127')
	local func = loadstring("return " .. text)
	if not func then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:130')
		return false
	end

	rawset(game, "player", player)

	local suc, var = pcall(func)

	rawset(game, "player", nil)

	if not suc then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:140')
		return false
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:143')
	return true, dump(var)
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug/model.lua:146')
return Public
