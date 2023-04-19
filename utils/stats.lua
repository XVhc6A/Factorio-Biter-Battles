local Public = {}

-- Get the mean value of a table
function Public.mean(t)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/stats.lua:3')
	local sum = 0
	local count = 0

	for k, v in pairs(t) do
		if type(v) == "number" then
			sum = sum + v
			count = count + 1
		end
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/stats.lua:14')
	return (sum / count)
end

-- Get the mode of a table.  Returns a table of values.
-- Works on anything (not just numbers).
function Public.mode(t)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/stats.lua:19')
	local counts = {}

	for k, v in pairs(t) do
		if counts[v] == nil then
			counts[v] = 1
		else
			counts[v] = counts[v] + 1
		end
	end

	local biggestCount = 0

	for k, v in pairs(counts) do
		if v > biggestCount then
			biggestCount = v
		end
	end

	local temp = {}

	for k, v in pairs(counts) do
		if v == biggestCount then
			table.insert(temp, k)
		end
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/stats.lua:46')
	return temp
end

-- Get the median of a table.
function Public.median(t)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/stats.lua:50')
	local temp = {}

	-- deep copy table so that when we sort it, the original is unchanged
	-- also weed out any non numbers
	for k, v in pairs(t) do
		if type(v) == "number" then
			table.insert(temp, v)
		end
	end

	table.sort(temp)

	-- If we have an even number of table elements or odd.
	if math.fmod(#temp, 2) == 0 then
		-- return mean value of middle two elements
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/stats.lua:66')
		return (temp[#temp / 2] + temp[(#temp / 2) + 1]) / 2
	else
		-- return middle element
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/stats.lua:69')
		return temp[math.ceil(#temp / 2)]
	end
end

-- Get the standard deviation of a table
function Public.standardDeviation(t)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/stats.lua:74')
	local m
	local vm
	local sum = 0
	local count = 0
	local result

	m = Public.mean(t)

	for k, v in pairs(t) do
		if type(v) == "number" then
			vm = v - m
			sum = sum + (vm * vm)
			count = count + 1
		end
	end

	result = math.sqrt(sum / (count - 1))

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/stats.lua:93')
	return result
end

-- Get the max and min for a table
function Public.maxmin(t)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/stats.lua:97')
	local max = -math.huge
	local min = math.huge

	for k, v in pairs(t) do
		if type(v) == "number" then
			max = math.max(max, v)
			min = math.min(min, v)
		end
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/stats.lua:108')
	return max, min
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/stats.lua:111')
return Public
