-- localised functions
local format = string.format
local match = string.match
local gsub = string.gsub
local serialize = serpent.line
local debug_getupvalue = debug.getupvalue

-- this
local Debug = {}

global.debug_message_count = 0

---@return number next index
local function increment()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:13')
	local next = global.debug_message_count + 1
	global.debug_message_count = next

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:17')
	return next
end

--- Takes the table output from debug.getinfo and pretties it
local function cleanup_debug(debug_table)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:21')
	local short_src = match(debug_table.source, "/[^/]*/[^/]*$")
	-- require will not return a valid string so short_src may be nil here
	if short_src then
		short_src = gsub(short_src, "%.lua", "")
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:28')
	return format("[function: %s file: %s line number: %s]", debug_table.name, short_src, debug_table.currentline)
end

---Shows the given message if debug is enabled. Uses serpent to print non scalars.
-- @param message <table|string|number|boolean>
-- @param stack_traceback <number|nil> levels of stack trace to give, defaults to 1 level if nil
function Debug.print(message, trace_levels)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:34')
	if not _DEBUG then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:36')
		return
	end

	if not trace_levels then
		trace_levels = 2
	else
		trace_levels = trace_levels + 1
	end

	local traceback_string = ""
	if type(message) ~= "string" and type(message) ~= "number" and type(message) ~= "boolean" then
		message = serialize(message)
	end

	message = format("[%d] %s", increment(), tostring(message))

	if trace_levels >= 2 then
		for i = 2, trace_levels do
			local debug_table = debug.getinfo(i)
			if debug_table then
				traceback_string = format("%s -> %s", traceback_string, cleanup_debug(debug_table))
			else
				break
			end
		end
		message = format("%s - Traceback%s", message, traceback_string)
	end

	if _LIFECYCLE == _STAGE.runtime then
		game.print(message)
	end
	log(message)
end

local function get(obj, prop)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:70')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:71')
	return obj[prop]
end

local function get_lua_object_type_safe(obj)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:74')
	local s, r = pcall(get, obj, "help")

	if not s then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:78')
		return
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:81')
	return r():match("Lua%a+")
end

--- Returns the value of the key inside the object
-- or 'InvalidLuaObject' if the LuaObject is invalid.
-- or 'InvalidLuaObjectKey' if the LuaObject does not have an entry at that key
-- @param object <table> LuaObject or metatable
-- @param key <string>
-- @return <any>
function Debug.get_meta_value(object, key)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:90')
	if Debug.object_type(object) == "InvalidLuaObject" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:92')
		return "InvalidLuaObject"
	end

	local suc, value = pcall(get, object, key)
	if not suc then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:97')
		return "InvalidLuaObjectKey"
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:100')
	return value
end

--- Returns the Lua data type or the factorio LuaObject type
-- or 'NoHelpLuaObject' if the LuaObject does not have a help function
-- or 'InvalidLuaObject' if the LuaObject is invalid.
-- @param object <any>
-- @return string
function Debug.object_type(object)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:108')
	local obj_type = type(object)

	if obj_type ~= "table" or type(object.__self) ~= "userdata" then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:112')
		return obj_type
	end

	local suc, valid = pcall(get, object, "valid")
	if not suc then
		-- no 'valid' property
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:118')
		return get_lua_object_type_safe(object) or "NoHelpLuaObject"
	end

	if not valid then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:122')
		return "InvalidLuaObject"
	else
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:124')
		return get_lua_object_type_safe(object) or "NoHelpLuaObject"
	end
end

---Shows the given message if debug is on.
---@param position Position
---@param message string
function Debug.print_position(position, message)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:131')
	Debug.print(format("%s %s", serialize(position), message))
end

---Executes the given callback if cheating is enabled.
---@param callback function
function Debug.cheat(callback)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:137')
	if _CHEATS then
		callback()
	end
end

--- Returns true if the function is a closure, false otherwise.
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:143')
-- A closure is a function that contains 'upvalues' or in other words
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:144')
-- has a reference to a local variable defined outside the function's scope.
-- @param  func<function>
-- @return boolean
function Debug.is_closure(func)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:148')
	local i = 1
	while true do
		local n = debug_getupvalue(func, i)

		if n == nil then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:154')
			return false
		elseif n ~= "_ENV" then
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:156')
			return true
		end

		i = i + 1
	end
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/debug.lua:163')
return Debug
