-- Threading simulation module
-- Task.sleep()
-- @author Valansch and Grilledham
-- github: https://github.com/Refactorio/RedMew
-- ======================================================= --

local Queue = require("utils.queue")
local PriorityQueue = require("utils.priority_queue")
local Event = require("utils.event")
local Token = require("utils.token")
local Global = require("utils.global")

local floor = math.floor
local log10 = math.log10
local Token_get = Token.get
local pcall = pcall
local Queue_peek = Queue.peek
local Queue_pop = Queue.pop
local Queue_push = Queue.push
local PriorityQueue_peek = PriorityQueue.peek
local PriorityQueue_pop = PriorityQueue.pop
local PriorityQueue_push = PriorityQueue.push

local Task = {}

local function comparator(a, b)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:25')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:26')
	return a.time < b.time
end

local callbacks = PriorityQueue.new(comparator)
local task_queue = Queue.new()
local primitives = {
	next_async_callback_time = -1,
	total_task_weight = 0,
	task_queue_speed = 1,
	task_per_tick = 1,
}

Global.register({ callbacks = callbacks, task_queue = task_queue, primitives = primitives }, function(tbl)
	callbacks = tbl.callbacks
	task_queue = tbl.task_queue
	primitives = tbl.primitives

	PriorityQueue.load(callbacks, comparator)
end)

local function get_task_per_tick(tick)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:46')
	if tick % 300 == 0 then
		local size = primitives.total_task_weight
		local task_per_tick = floor(log10(size + 1)) * primitives.task_queue_speed
		if task_per_tick < 1 then
			task_per_tick = 1
		end

		primitives.task_per_tick = task_per_tick
		log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:55')
		return task_per_tick
	end
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:57')
	return primitives.task_per_tick
end

local function on_tick()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:60')
	local tick = game.tick

	for i = 1, get_task_per_tick(tick) do
		local task = Queue_peek(task_queue)
		if task ~= nil then
			-- result is error if not success else result is a boolean for if the task should stay in the queue.
			local success, result = pcall(Token_get(task.func_token), task.params)
			if not success then
				if _DEBUG then
					error(result)
				else
					log(result)
				end
				Queue_pop(task_queue)
				primitives.total_task_weight = primitives.total_task_weight - task.weight
			elseif not result then
				Queue_pop(task_queue)
				primitives.total_task_weight = primitives.total_task_weight - task.weight
			end
		end
	end

	local callback = PriorityQueue_peek(callbacks)
	while callback ~= nil and tick >= callback.time do
		local success, result = pcall(Token_get(callback.func_token), callback.params)
		if not success then
			if _DEBUG then
				error(result)
			else
				log(result)
			end
		end
		PriorityQueue_pop(callbacks)
		callback = PriorityQueue_peek(callbacks)
	end
end

--- Allows you to set a timer (in ticks) after which the tokened function will be run with params given as an argument
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:98')
-- Cannot be called before init
-- @param ticks <number>
-- @param func_token <number> a token for a function store via the token system
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:101')
-- @param params <any> the argument to send to the tokened function
function Task.set_timeout_in_ticks(ticks, func_token, params)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:103')
	if not game then
		error("cannot call when game is not available", 2)
	end
	local time = game.tick + ticks
	local callback = { time = time, func_token = func_token, params = params }
	PriorityQueue_push(callbacks, callback)
end

--- Allows you to set a timer (in seconds) after which the tokened function will be run with params given as an argument
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:112')
-- Cannot be called before init
-- @param sec <number>
-- @param func_token <number> a token for a function store via the token system
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:115')
-- @param params <any> the argument to send to the tokened function
function Task.set_timeout(sec, func_token, params)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:117')
	if not game then
		error("cannot call when game is not available", 2)
	end
	Task.set_timeout_in_ticks(60 * sec, func_token, params)
end

--- Queueing allows you to split up heavy tasks which don't need to be completed in the same tick.
-- Queued tasks are generally run 1 per tick. If the queue backs up, more tasks will be processed per tick.
-- @param func_token <number> a token for a function stored via the token system
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:126')
-- If this function returns `true` it will run again the next tick, delaying other queued tasks (see weight)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:127')
-- @param params <any> the argument to send to the tokened function
-- @param weight <number> (defaults to 1) weight is the number of ticks a task is expected to take.
-- Ex. if the task is expected to repeat multiple times (ie. the function returns true and loops several ticks)
log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:130')
function Task.queue_task(func_token, params, weight)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:131')
	weight = weight or 1
	primitives.total_task_weight = primitives.total_task_weight + weight
	Queue_push(task_queue, { func_token = func_token, params = params, weight = weight })
end

function Task.get_queue_speed()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:137')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:138')
	return primitives.task_queue_speed
end

function Task.set_queue_speed(value)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:141')
	value = value or 1
	if value < 0 then
		value = 0
	end

	primitives.task_queue_speed = value
end

function Task.start_queue()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:150')
	if task_queue._tail == 0 then
		task_queue._tail = 1
	end
end

function Task.get_task_queue()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:156')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:157')
	return task_queue
end

Event.add(defines.events.on_tick, on_tick)

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/task.lua:162')
return Task
