-- -----------------------------------------------------------------
-- Fabrica
-- linkedlist.lua
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

--- A node contaning a `value` and a reference (`next`) to another
--- linked list node.
---
--- Example:
--- ```
--- -- Linear linked list implementation:
--- local node2 = LinkedListNode(5, nil)
--- local node1 = LinkedListNode(5, node2)
--- local node0 = LinkedListNode(5, node1)
--- ```
---
--- Example:
--- ```
--- -- Cylic linked list implementation:
--- local node1 = LinkedListNode(5, nil)
--- local node0 = LinkedListNode(5, node1)
--- node1.next = node0
--- ```
---
--- **Cyclic lists where the end references the start as next
--- are much faster and more supported than cyclic lists where
--- the end node references a median value due to the iteration
--- cap and how iterations are handled.**
---
--- **The max properly supported size of a linked list is `163854`
--- by default, this is the same as `LinkedListNode.ITERATION_CAP`,
--- which can be changed globally.**
--- @generic T, N
--- @class LinkedListNode<T>
--- The value this node contains.
--- @field value T
--- The next node in the linked list sequence.
--- @field next LinkedListNode<N>
--- @overload fun(value: T?, next: LinkedListNode<N>?): LinkedListNode<T>
local LinkedListNode = Class()

--- The index at which the linked tree iterations stop, every
--- iteration is one-indexed to keep the lua tradition. The
--- `LinkedListNode:skip(self, steps)` iteration is excempt
--- from this.
--- @type integer
LinkedListNode.ITERATION_CAP = 163854

local function cap_iteration(i)
	if i > LinkedListNode.ITERATION_CAP then
		warn("Linked list iteration hit a cap.")
		return true
	end
	return false
end

Class.constructor(LinkedListNode, function(value, next)
	return Class.new(LinkedListNode, {
		_value = value,
		_next = next
	})
end)

--- Does `steps` many next operations over the linked list node.
--- If `steps` is less then the number of nodes after this one
--- this returns `nil` instead.
---
--- Example:
--- ```
--- local node2 = LinkedListNode(5, nil)
--- local node1 = LinkedListNode(5, node2)
--- local node0 = LinkedListNode(5, node1)
--- assert(node0.next.next == node0:skip(2))
--- ```
--- @param steps integer
--- @return LinkedListNode?
function LinkedListNode:skip(steps)
	local current = self
	for _ = 1, steps, 1 do
		if current == nil then return nil end
		current = current.next
	end
	return current
end

--- Returns wheather the node is the end node or not, meaning
--- it has no next set, this is always `false` on cyclic linked
--- list nodes.
--- @return boolean
function LinkedListNode:is_end()
	return self.next == nil
end

--- Returns wheather the entire linked list is cyclic (the ending
--- node references the starting node) or not.
---
--- Returns `true` if the iteration cap was reached, since that
--- is the maximum size for a linked list.
--- @return boolean
function LinkedListNode:is_cyclic()
	local current = self
	local iterations = 1
	while current ~= nil do
		iterations = iterations + 1
		if cap_iteration(iterations) then return true end
		current = current.next
		if current == self then return true end
	end
	return false
end

--- Returns wheather the entire linked list is linear (the ending
--- node references `nil`) or not.
---
--- Returns `false` if the iteration cap was reached, since that
--- is the maximum size for a linked list.
--- @return boolean
function LinkedListNode:is_linear()
	local current = self
	local iterations = 1
	while current ~= nil do
		iterations = iterations + 1
		if cap_iteration(iterations) then return false end
		current = current.next
		if current == self then return false end
	end
	return true
end

local function list_next(head, current)
	local next_node = (current == nil) and head or current.next

	if next_node == nil then return nil end
	if current ~= nil and next_node == head then return nil end

	return next_node, next_node.value
end

--- Returns a stateless iterator function over the values of the
--- nodes in this linked list starting from this node to be used
--- in a for loop.
---
--- Example:
--- ```
--- local node1 = LinkedListNode("foo", nil)
--- local node0 = LinkedListNode("bar", node1)
--- node1.next = node0
--- local iterations = 0
--- for _value in node0:iter() do
---  iterations = iterations + 1
--- end
--- assert(iterations == 2)
--- ```
--- @return fun(state: LinkedListNode, var: LinkedListNode): LinkedListNode, any
--- @return LinkedListNode
--- @return nil
function LinkedListNode:iter()
	return list_next, self, nil
end

--- Iterates over the nodes in the linked list starting from this
--- node, calling `func(v)` where `v`: value of the node for each
--- node. To iterate over *every* node in a linear linked list,
--- call this on the starting node.
--- @param func fun(value: any)
function LinkedListNode:foreach(func)
	local current = self
	local iterations = 1
	while current ~= nil do
		iterations = iterations + 1
		if cap_iteration(iterations) then break end
		func(current.value)
		current = current.next
		if current == self then return end
	end
end

--- Iterates over the nodes in the linked list starting from this
--- node, calling `func(v)` where `v`: value of the node for each
--- node and changing the value of the current node to the return
--- value. To iterate over *every* node in a linear linked list,
--- call this on the starting node.
--- @param func fun(value: any): any
function LinkedListNode:map(func)
	local current = self
	local iterations = 1
	while current ~= nil do
		iterations = iterations + 1
		if cap_iteration(iterations) then break end
		local new_value = func(current.value)
		current.value = new_value
		current = current.next
		if current == self then return end
	end
end

--- Iterates over each node in the linked list starting from
--- this node, adding them to a `list`, returning the resulting
--- `list`.
--- @return table
function LinkedListNode:collect()
	local collection = {}
	self:foreach(function(v)
		table.insert(collection, v)
	end)
	return collection
end

--- Iterates over each node in the linked list starting from
--- this node, adding them to a `table` with key value pairs
--- `key_generator(v): v` returning the resulting `table`.
---
--- Since two keys of the same value cannot be in the same
--- table, the later node's value will be used when two
--- same keys are generated.
--- @param key_generator fun(value: any): any
--- @return table
function LinkedListNode:collect_pairs(key_generator)
	local collection = {}
	self:foreach(function(v)
		collection[key_generator(v)] = v
	end)
	return collection
end

--- Iterates over each node in the linked list starting from
--- this node, adding them to a `table` with key value pairs
--- `v: value_generator(v)` returning the resulting `table`.
---
--- Since two keys of the same value cannot be in the same
--- table, the later node's generated value will be used when
--- two same keys are present.
--- @param value_generator any
--- @return table
function LinkedListNode:collect_kpairs(value_generator)
	local collection = {}
	self:foreach(function(v)
		collection[v] = value_generator(v)
	end)
	return collection
end

--- Iterates over each node in the linked list starting from
--- this node, adding them to a `table` with key value pairs
--- `key_generator(v): value_generator(v)` returning the
--- resulting `table`.
---
--- Since two keys of the same value cannot be in the same
--- table, the later node's generated value will be used when
--- two same keys are generated.
--- @param key_generator any
--- @param value_generator any
--- @return table
function LinkedListNode:collect_kvpairs(key_generator, value_generator)
	local collection = {}
	self:foreach(function(v)
		collection[key_generator(v)] = value_generator(v)
	end)
	return collection
end

return LinkedListNode
