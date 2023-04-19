-- Minimal FIFO implementation. It guarantees constant insertion and erase
-- times. It uses pool allocator to amortize cost of garbage collection.
local pool = require("maps.biter_battles_v2.pool")
local mod = {}

function mod.init()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:5')
	global.fifo_store = {}
	global.fifo_idx = {}
	global.fifo_capacity = {}
	global.fifo_id = 0
end

function mod.create(size)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:12')
	global.fifo_id = global.fifo_id + 1
	global.fifo_store[global.fifo_id] = pool.malloc(size)
	global.fifo_idx[global.fifo_id] = 0
	global.fifo_capacity[global.fifo_id] = size

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:18')
	return global.fifo_id
end

function mod.destroy(id)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:21')
	global.fifo_store[id] = nil
	global.fifo_idx[id] = nil
	global.fifo_capacity[id] = nil
end

function mod.empty(id)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:27')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:28')
	return global.fifo_idx[id] == 0
end

function mod.push(id, val)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:31')
	-- This method will unlink reference to existing value
	-- which will trigger GC. Currently cannot do anything
	-- about it.
	global.fifo_idx[id] = global.fifo_idx[id] + 1

	local idx = global.fifo_idx[id]
	local size = global.fifo_capacity[id]
	if size < idx then
		global.fifo_store[id] = pool.enlarge(global.fifo_store[id], size, 100)
		global.fifo_capacity[id] = global.fifo_capacity[id] + 100
	end

	global.fifo_store[id][idx] = val
end

function mod.pop(id)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:47')
	local idx = global.fifo_idx[id]
	local ref = global.fifo_store[id][idx]

	-- Popping element just involves decreasing the fifo index. In case something
	-- gets pushed right after pop, values will be just overwritten.
	global.fifo_idx[id] = global.fifo_idx[id] - 1
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:54')
	return ref
end

function mod.length(id)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:57')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:58')
	return global.fifo_idx[id]
end

function mod.capacity(id)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:61')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:62')
	return global.fifo_capacity[id]
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/maps/biter_battles_v2/fifo.lua:65')
return mod
