local inspect = {
	_VERSION = "inspect.lua 3.1.0",
	_URL = "http://github.com/kikito/inspect.lua",
	_DESCRIPTION = "human-readable representations of tables",
	_LICENSE = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]],
}

local tostring = tostring

inspect.KEY = setmetatable({}, {
	__tostring = function()
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:33')
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:34')
		return "inspect.KEY"
	end,
})
inspect.METATABLE = setmetatable({}, {
	__tostring = function()
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:38')
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:39')
		return "inspect.METATABLE"
	end,
})

-- Apostrophizes the string if it has quotes, but not aphostrophes
-- Otherwise, it returns a regular quoted string
local function smartQuote(str)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:45')
	if str:match('"') and not str:match("'") then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:47')
		return "'" .. str .. "'"
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:49')
	return '"' .. str:gsub('"', '\\"') .. '"'
end

-- \a => '\\a', \0 => '\\0', 31 => '\31'
local shortControlCharEscapes = {
	["\a"] = "\\a",
	["\b"] = "\\b",
	["\f"] = "\\f",
	["\n"] = "\\n",
	["\r"] = "\\r",
	["\t"] = "\\t",
	["\v"] = "\\v",
}
local longControlCharEscapes = {} -- \a => nil, \0 => \000, 31 => \031
for i = 0, 31 do
	local ch = string.char(i)
	if not shortControlCharEscapes[ch] then
		shortControlCharEscapes[ch] = "\\" .. i
		longControlCharEscapes[ch] = string.format("\\%03d", i)
	end
end

local function escape(str)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:71')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:72')
	return (str:gsub("\\", "\\\\"):gsub("(%c)%f[0-9]", longControlCharEscapes):gsub("%c", shortControlCharEscapes))
end

local function isIdentifier(str)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:75')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:76')
	return type(str) == "string" and str:match("^[_%a][_%a%d]*$")
end

local function isSequenceKey(k, sequenceLength)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:79')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:80')
	return type(k) == "number" and 1 <= k and k <= sequenceLength and math.floor(k) == k
end

local defaultTypeOrders = {
	["number"] = 1,
	["boolean"] = 2,
	["string"] = 3,
	["table"] = 4,
	["function"] = 5,
	["userdata"] = 6,
	["thread"] = 7,
}

local function sortKeys(a, b)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:93')
	local ta, tb = type(a), type(b)

	-- strings and numbers are sorted numerically/alphabetically
	if ta == tb and (ta == "string" or ta == "number") then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:98')
		return a < b
	end

	local dta, dtb = defaultTypeOrders[ta], defaultTypeOrders[tb]
	-- Two default types are compared according to the defaultTypeOrders table
	if dta and dtb then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:104')
		return defaultTypeOrders[ta] < defaultTypeOrders[tb]
	elseif dta then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:106')
		return true -- default types before custom ones
	elseif dtb then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:108')
		return false -- custom types after default ones
	end

	-- custom types are sorted out alphabetically
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:112')
	return ta < tb
end

-- For implementation reasons, the behavior of rawlen & # is "undefined" when
-- tables aren't pure sequences. So we implement our own # operator.
local function getSequenceLength(t)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:117')
	local len = 1
	local v = rawget(t, len)
	while v ~= nil do
		len = len + 1
		v = rawget(t, len)
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:124')
	return len - 1
end

local function getNonSequentialKeys(t)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:127')
	local keys = {}
	local sequenceLength = getSequenceLength(t)
	for k, _ in pairs(t) do
		if not isSequenceKey(k, sequenceLength) then
			table.insert(keys, k)
		end
	end
	table.sort(keys, sortKeys)
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:136')
	return keys, sequenceLength
end

local function getToStringResultSafely(t, mt)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:139')
	local __tostring = type(mt) == "table" and rawget(mt, "__tostring")
	local str, ok
	if type(__tostring) == "function" then
		ok, str = pcall(__tostring, t)
		str = ok and str or "error: " .. tostring(str)
	end
	if type(str) == "string" and #str > 0 then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:147')
		return str
	end
end

local function countTableAppearances(t, tableAppearances)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:151')
	tableAppearances = tableAppearances or {}

	if type(t) == "table" then
		if not tableAppearances[t] then
			tableAppearances[t] = 1
			for k, v in pairs(t) do
				countTableAppearances(k, tableAppearances)
				countTableAppearances(v, tableAppearances)
			end
			countTableAppearances(getmetatable(t), tableAppearances)
		else
			tableAppearances[t] = tableAppearances[t] + 1
		end
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:167')
	return tableAppearances
end

local copySequence = function(s)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:170')
	local copy, len = {}, #s
	for i = 1, len do
		copy[i] = s[i]
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:175')
	return copy, len
end

local function makePath(path, ...)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:178')
	local keys = { ... }
	local newPath, len = copySequence(path)
	for i = 1, #keys do
		newPath[len + i] = keys[i]
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:184')
	return newPath
end

local function processRecursive(process, item, path, visited)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:187')
	if item == nil then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:189')
		return nil
	end
	if visited[item] then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:192')
		return visited[item]
	end

	local processed = process(item, path)
	if type(processed) == "table" then
		local processedCopy = {}
		visited[item] = processedCopy
		local processedKey

		for k, v in pairs(processed) do
			processedKey = processRecursive(process, k, makePath(path, k, inspect.KEY), visited)
			if processedKey ~= nil then
				processedCopy[processedKey] = processRecursive(process, v, makePath(path, processedKey), visited)
			end
		end

		local mt = processRecursive(process, getmetatable(processed), makePath(path, inspect.METATABLE), visited)
		setmetatable(processedCopy, mt)
		processed = processedCopy
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:212')
	return processed
end

-------------------------------------------------------------------

local Inspector = {}
local Inspector_mt = { __index = Inspector }

function Inspector:puts(...)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:220')
	local args = { ... }
	local buffer = self.buffer
	local len = #buffer
	for i = 1, #args do
		len = len + 1
		buffer[len] = args[i]
	end
end

function Inspector:down(f)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:230')
	self.level = self.level + 1
	f()
	self.level = self.level - 1
end

function Inspector:tabify()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:236')
	self:puts(self.newline, string.rep(self.indent, self.level))
end

function Inspector:alreadyVisited(v)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:240')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:241')
	return self.ids[v] ~= nil
end

function Inspector:getId(v)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:244')
	local id = self.ids[v]
	if not id then
		local tv = type(v)
		id = (self.maxIds[tv] or 0) + 1
		self.maxIds[tv] = id
		self.ids[v] = id
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:252')
	return tostring(id)
end

function Inspector:putKey(k)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:255')
	if isIdentifier(k) then
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:257')
		return self:puts(k)
	end
	self:puts("[")
	self:putValue(k)
	self:puts("]")
end

function Inspector:putTable(t)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:264')
	if t == inspect.KEY or t == inspect.METATABLE then
		self:puts(tostring(t))
	elseif self:alreadyVisited(t) then
		self:puts("<table ", self:getId(t), ">")
	elseif self.level >= self.depth then
		self:puts("{...}")
	else
		if self.tableAppearances[t] > 1 then
			self:puts("<", self:getId(t), ">")
		end

		local nonSequentialKeys, sequenceLength = getNonSequentialKeys(t)
		local mt = getmetatable(t)
		local toStringResult = getToStringResultSafely(t, mt)

		self:puts("{")
		self:down(function()
			if toStringResult then
				self:puts(" -- ", escape(toStringResult))
				if sequenceLength >= 1 then
					self:tabify()
				end
			end

			local count = 0
			for i = 1, sequenceLength do
				if count > 0 then
					self:puts(",")
				end
				self:puts(" ")
				self:putValue(t[i])
				count = count + 1
			end

			for _, k in ipairs(nonSequentialKeys) do
				if count > 0 then
					self:puts(",")
				end
				self:tabify()
				self:putKey(k)
				self:puts(" = ")
				self:putValue(t[k])
				count = count + 1
			end

			if mt then
				if count > 0 then
					self:puts(",")
				end
				self:tabify()
				self:puts("<metatable> = ")
				self:putValue(mt)
			end
		end)

		if #nonSequentialKeys > 0 or mt then -- result is multi-lined. Justify closing }
			self:tabify()
		elseif sequenceLength > 0 then -- array tables have one extra space before closing }
			self:puts(" ")
		end

		self:puts("}")
	end
end

function Inspector:putValue(v)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:330')
	local tv = type(v)

	if tv == "string" then
		self:puts(smartQuote(escape(v)))
	elseif tv == "number" or tv == "boolean" or tv == "nil" or tv == "cdata" or tv == "ctype" then
		self:puts(tostring(v))
	elseif tv == "table" then
		self:putTable(v)
	else
		self:puts("<", tv, " ", self:getId(v), ">")
	end
end

-------------------------------------------------------------------

function inspect.inspect(root, options)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:346')
	options = options or {}

	local depth = options.depth or math.huge
	local newline = options.newline or "\n"
	local indent = options.indent or "  "
	local process = options.process

	if process then
		root = processRecursive(process, root, {}, {})
	end

	local inspector = setmetatable({
		depth = depth,
		level = 0,
		buffer = {},
		ids = {},
		maxIds = {},
		newline = newline,
		indent = indent,
		tableAppearances = countTableAppearances(root),
	}, Inspector_mt)

	inspector:putValue(root)

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:371')
	return table.concat(inspector.buffer)
end

setmetatable(inspect, {
	__call = function(_, ...)
		log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:375')
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:376')
		return inspect.inspect(...)
	end,
})

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/inspect.lua:380')
return inspect
