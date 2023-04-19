local Queue = {}

function Queue.new()
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:2')
	local queue = {
		_head = 1,
		_tail = 0,
	}
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:7')
	return queue
end

function Queue.size(queue)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:10')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:11')
	return queue._head - queue._tail
end

function Queue.push(queue, element)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:14')
	local index = queue._head
	queue[index] = element
	queue._head = index + 1
end

--- Pushes the element such that it would be the next element pop'ed.
function Queue.push_to_end(queue, element)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:21')
	local index = queue._tail - 1
	queue[index] = element
	queue._tail = index
end

function Queue.empty(queue)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:27')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:28')
	return queue._head > queue._tail
end

function Queue.peek(queue)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:31')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:32')
	return queue[queue._tail]
end

function Queue.peek_first(queue)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:35')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:36')
	return queue[queue._head]
end

function Queue.peek_start(queue)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:39')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:40')
	return queue[queue._head - 1]
end

function Queue.peek_index(queue, index)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:43')
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:44')
	return queue[queue._tail + index - 1]
end

function Queue.pop(queue)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:47')
	local index = queue._tail

	local element = queue[index]
	queue[index] = nil

	if element then
		queue._tail = index + 1
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:57')
	return element
end

function Queue.to_array(queue)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:60')
	local n = 1
	local res = {}

	for i = queue._tail, queue._head - 1 do
		res[n] = queue[i]
		n = n + 1
	end

	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:69')
	return res
end

function Queue.pairs(queue)
	log('Func start /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:72')
	local index = queue._tail
	log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:74')
	return function()
		local element = queue[index]

		if element then
			local old = index
			index = index + 1
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:80')
			return old, element
		else
			log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:82')
			return nil
		end
	end
end

log('Func ret /Users/drbuttons/git/Factorio-Biter-Battles/utils/queue.lua:87')
return Queue
