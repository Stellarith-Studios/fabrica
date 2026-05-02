-- -----------------------------------------------------------------
-- Fabrica
-- queue.lua
-- -----------------------------------------------------------------
-- Copyright (c) 2026 Stellarith Studios
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
-- USE OR OTHER DEALINGS IN THE SOFTWARE.
-- -----------------------------------------------------------------
-- File Authors:
--   - Yarkın
-- -----------------------------------------------------------------
require("stellarith.fabrica.class")

--- A special list containing elements of `any` type. Follows the
--- principle of *First in First out*, (FIFO) where the first element
--- added to the queue is the first one to be removed. (popped)
--- @class Queue
--- The list of elements remaining on the queue.
--- @field remaining table<integer, any>

--- @overload fun(...: any): Queue
Queue = Class()

constructor(Queue, function(...)
	return new(Queue, { _remaining = { ... } })
end)

--- @class Queue
--- Creates a queue out of the given `list`.
---
--- Due to performance reasons, this has no checks if the `list` is
--- actually a list or a key value pairs table.
--- @field from_list fun(list: table<integer, any>): Queue

--- Creates a queue out of the given `list`.
---
--- Due to performance reasons, this has no checks if the `list` is
--- actually a list or a key value pairs table.
--- @param list table<integer, any>
--- @return Queue
function Queue.from_list(list)
	return new(Queue, { _remaining = list })
end

--- @class Queue
--- Creates a queue out of the given `table`, adding all integer keyed
--- values to the queue while skipping others.
--- @field from_table fun(tbl: table<any, any>): Queue

--- Creates a queue out of the given `table`, adding all integer keyed
--- values to the queue while skipping others.
--- @param tbl table<any, any>
--- @return Queue
function Queue.from_table(tbl)
	local list = {}
	for _, element in ipairs(tbl) do
		table.insert(list, element)
	end
	return Queue.from_list(list)
end

--- @class Queue
--- Adds the `element` to the queue.
--- @field push fun(self: Queue, element: any)

--- Adds the `element` to the queue.
--- @param element any
function Queue:push(element)
	table.insert(self.remaining, element)
end

--- @class Queue
--- Removes the first element from the queue.
--- @field pop fun(self: Queue): any

--- Removes the first element from the queue.
--- @return any
function Queue:pop()
	return table.remove(self.remaining, 1)
end

--- @class Queue
--- Clears the queue, removing all remaining elements. (Abandons the
--- previous list, leaving the garbage collector to deallocate it)
--- @field clear fun(self: Queue)

--- Clears the queue, removing all remaining elements. (Abandons the
--- previous list, leaving the garbage collector to deallocate it)
function Queue:clear()
	self.remaining = {}
end

--- @class Queue
--- Returns wheather the queue is empty or not.
--- @field is_empty fun(self: Queue): boolean

--- Returns wheather the queue is empty or not.
--- @return boolean
function Queue:is_empty()
	return #self.remaining < 1
end

--- @class Queue
--- Iterates over the elements of the queue. Calls `func(e)` for each
--- element `e` there is.
--- @field foreach fun(self: Queue, func: fun(element: any))

--- Iterates over the elements of the queue. Calls `func(e)` for each
--- element `e` there is.
--- @param func fun(element: any)
function Queue:foreach(func)
	for _, element in self.remaining do
		func(element)
	end
end

--- @class Queue
--- Iterates over the elements of the queue, mapping each element to
--- the return value of `func(e)` for each element `e` there is.
--- @field map fun(self: Queue, func: fun(element: any): any)

--- Iterates over the elements of the queue, mapping each element to
--- the return value of `func(e)` for each element `e` there is.
--- @param func fun(element: any): any
function Queue:map(func)
	local remaining = {}
	for _, element in self.remaining do
		table.insert(remaining, func(element))
	end
	self.remaining = remaining
end

--- @class Queue
--- Creates a new set iterating over the elements of the original
--- set, mapping each element to the return value of `func(e)`
--- for each element `e` there is.
--- @field mapped fun(self: Queue, func: fun(element: any): any): Queue

--- Creates a new set iterating over the elements of the original
--- set, mapping each element to the return value of `func(e)`
--- for each element `e` there is.
--- @param func fun(element: any): any
--- @return Queue
function Queue:mapped(func)
	local remaining = {}
	for _, element in self.remaining do
		table.insert(remaining, func(element))
	end
	return Queue.from_list(remaining)
end

--- @class Queue
--- Pops elements in the queue until `func(e)` for each popped
--- element `e` there is evaluates to `false` or `nil`.
--- @field pop_until fun(self: Queue, func: fun(element: any): boolean)

--- Pops elements in the queue until `func(e)` for each popped
--- element `e` there is evaluates to `false` or `nil`.
--- @param func fun(element: any): boolean
function Queue:pop_until(func)
	local element = self:pop()
	while element do
		if not func(element) then return end
		element = self:pop()
	end
end

--- @class Queue
--- Pops every element in the queue, calling `func(e)` for each
--- popped element `e` there is.
--- @field consume fun(self: Queue, func: fun(element: any))

--- Pops every element in the queue, calling `func(e)` for each
--- popped element `e` there is.
--- @param func fun(element: any)
function Queue:consume(func)
	local element = self:pop()
	while element do
		func(element)
		element = self:pop()
	end
end

return Queue
