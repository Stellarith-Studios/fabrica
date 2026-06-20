-- -----------------------------------------------------------------
-- Fabrica
-- stack.lua
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
--   - Yarkın Saatçi (xpoxy)
-- -----------------------------------------------------------------
local Class = require("stellarith.fabrica.class")

--- A special list containing elements of `any` type. Follows the
--- principle of *Last in First Out*, (LIFO) where the first element
--- added to the stack is the first one to be removed. (popped)
--- @class Stack
--- The list of elements remaining on the stack.
--- @field remaining table<integer, any>
--- @overload fun(...: any): Stack
Stack = Class()

Class.constructor(Stack, function(...)
	return Class.new(Stack, { _remaining = { ... } })
end)

--- Creates a stack out of the given `list`.
---
--- Due to performance reasons, this has no checks if the `list` is
--- actually a list or a key value pairs table.
--- @param list table<integer, any>
--- @return Stack
function Stack.from_list(list)
	return Class.new(Stack, { _remaining = list })
end

--- Creates a stack out of the given `table`, adding all integer keyed
--- values to the stack while skipping others.
--- @param tbl table<any, any>
--- @return Stack
function Stack.from_table(tbl)
	local list = {}
	for _, element in ipairs(tbl) do
		table.insert(list, element)
	end
	return Stack.from_list(list)
end

--- Adds the `element` to the stack.
--- @param element any
function Stack:push(element)
	table.insert(self.remaining, element)
end

--- Removes the last element from the stack.
--- @return any
function Stack:pop()
	return table.remove(self.remaining, #self.remaining)
end

--- Clears the stack, removing all remaining elements. (Abandons the
--- previous list, leaving the garbage collector to deallocate it)
function Stack:clear()
	self.remaining = {}
end

Class.len_op(Stack, function(inst)
	return #inst.remaining
end)

--- Returns wheather the stack is empty or not.
--- @return boolean
function Stack:is_empty()
	return #self < 1
end

Class.iterator(Stack, function(inst)
	return pairs(inst.remaining)
end)

--- Iterates over the elements of the stack. Calls `func(e)` for each
--- element `e` there is.
--- @param func fun(element: any)
function Stack:foreach(func)
	for _, element in self.remaining do
		func(element)
	end
end

--- Iterates over the elements of the stack, mapping each element to
--- the return value of `func(e)` for each element `e` there is.
--- @param func fun(element: any): any
function Stack:map(func)
	local remaining = {}
	for _, element in self.remaining do
		table.insert(remaining, func(element))
	end
	self.remaining = remaining
end

--- Creates a new set iterating over the elements of the original
--- set, mapping each element to the return value of `func(e)`
--- for each element `e` there is.
--- @param func fun(element: any): any
--- @return Stack
function Stack:mapped(func)
	local remaining = {}
	for _, element in self.remaining do
		table.insert(remaining, func(element))
	end
	return Stack.from_list(remaining)
end

--- Pops elements in the stack until `func(e)` for each popped
--- element `e` there is evaluates to `false` or `nil`.
--- @param func fun(element: any): boolean
function Stack:pop_until(func)
	local element = self:pop()
	while element do
		if not func(element) then return end
		element = self:pop()
	end
end

--- Pops every element in the stack, calling `func(e)` for each
--- popped element `e` there is.
--- @param func fun(element: any)
function Stack:consume(func)
	local element = self:pop()
	while element do
		func(element)
		element = self:pop()
	end
end

return Stack
