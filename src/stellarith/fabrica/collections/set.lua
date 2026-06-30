-- -----------------------------------------------------------------
-- Fabrica
-- set.lua
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
local table = require("stellarith.fabrica.extensions.table")

--- A special list containing unique elements only once. Indexing
--- elements have a time complexity of `O(1)`.
---
--- Example:
--- ```
--- local set = Set(1, 2, 3, {1, 2})
--- local other = Set.from_list({1, 2})
--- local intersect = set:intersection(other)
--- assert(#intersect == 2)
--- ```
--- @class Set
--- A table of key value _pairs_ of this set where keys are the
--- elements and the values are all `true`.
---
--- **Note:** An element of a set can not be of nil value.
--- @field entries table<any, boolean>
--- @overload fun(...: any): Set
local Set = Class()

local EXISTS = true

Class.constructor(Set, function(...)
	local entries = {}
	for _, element in ipairs({ ... }) do
		entries[element] = EXISTS
	end
	return Class.new(Set, { _entries = entries })
end)

--- Creates a new set from the `list`. Uses `ipairs`
--- so only array-like elements will be included.
--- @param list table
--- @return Set
function Set.from_list(list)
	local entries = {}
	for _, element in ipairs(list) do
		entries[element] = EXISTS
	end
	return Class.new(Set, { _entries = entries })
end

--- Checks if a certain `element` is added to this set.
--- @param element any
--- @return boolean
function Set:contains(element)
	return self.entries[element] == EXISTS
end

--- Adds a new element to the set
--- @param element any
function Set:push(element)
	if element == nil then return end
	self.entries[element] = EXISTS
end

--- Removes an element from the set, if it exists.
--- @param element any
function Set:remove(element)
	if element == nil then return end
	self.entries[element] = nil
end

--- Removes every element from the set.
function Set:clear()
	table.clear(self.entries)
end

Class.len_op(Set,
	--- Returns the size of the set.
	--- @param inst Set
	--- @return integer
	function(inst)
		local size = 0
		for _, _ in pairs(inst.entries) do
			size = size + 1
		end
		return size
	end)

--- Returns wheather this set is empty or not, identical to the value
--- of `#self < 1`.
--- @return boolean
function Set:is_empty()
	return #self < 1
end

Class.iterator(Set,
	--- Returns a stateless iterator function over the elements of this
	--- set to be used in a for loop.
	---
	--- Example:
	--- ```
	--- local set = Set(3, 5, "foo", "bar")
	--- for element in pairs(set) do
	---     assert(set.entries[element])
	--- end
	--- ```
	--- @return function
	--- @return table<any, boolean>
	function(inst)
		return next, inst.entries
	end)

--- Iterates over the elements of the set. Calls `func(e)` for each
--- element `e` there is.
--- @param func fun(element: any)
function Set:foreach(func)
	for element, _ in pairs(self.entries) do
		func(element)
	end
end

--- Iterates over the elements of the set, mapping each element to
--- the return value of `func(e)` for each element `e` there is.
--- Returns the same set with mapped values.
--- @param func fun(element: any): any
--- @return Set
function Set:map(func)
	local entries = {}
	for element, _ in pairs(self.entries) do
		entries[func(element)] = EXISTS
	end
	self.entries = entries

	return self
end

--- Creates a new set iterating over the elements of the original
--- set, mapping each element to the return value of `func(e)`
--- for each element `e` there is.
--- @param func fun(element: any): any
--- @return Set
function Set:mapped(func)
	local set = Set()
	for element, _ in pairs(self.entries) do
		set:push(func(element))
	end
	return set
end

--- Iterates over the elements of the set, evaluating `func(e)` for
--- each element `e` there is, if the result is `true`, keeps it in
--- the set otherwise removes it.
--- @param func fun(element: any): boolean
function Set:filter(func)
	local entries = {}
	for element, _ in pairs(self.entries) do
		if func(element) == true then
			entries[element] = EXISTS
		end
	end
	self.entries = entries
end

--- Creates a new set iterating over the elements of the set, evaluating
--- `func(e)` for each element `e` there is, if the result is `true`,
--- adds it to the new set otherwise skips it.
--- @param func fun(element: any): boolean
--- @return Set
function Set:filtered(func)
	local set = Set()
	for element, _ in pairs(self.entries) do
		if func(element) == true then
			set:push(element)
		end
	end
	return set
end

--- Creates a table with keys consisting of elements of the set
--- and values generated by `value_generator(e)` for each element
--- `e` there is.
--- @param value_generator fun(element: any): any
--- @return table
function Set:pairs(value_generator)
	local tbl = {}
	for element, _ in pairs(self.entries) do
		tbl[element] = value_generator(element)
	end
	return tbl
end

--- Creates a table with values consisting of elements of the set
--- and keys generated by `key_generator(e)` for each element
--- `e` there is.
--- @param key_generator fun(element: any): any
--- @return table
function Set:kpairs(key_generator)
	local tbl = {}
	for element, _ in pairs(self.entries) do
		tbl[key_generator(element)] = element
	end
	return tbl
end

--- Creates a table with values generated by `value_generator(e)`
--- and keys generated by `key_generator(e)`.
--- @param key_generator fun(element: any): any
--- @param value_generator fun(element: any): any
--- @return table
function Set:kvpairs(key_generator, value_generator)
	local table = {}
	for element, _ in pairs(self.entries) do
		table[key_generator(element)] = value_generator(element)
	end
	return table
end

--- Creates a table with identical keys and values from the elements
--- of the set.
--- @return table
function Set:splat()
	local tbl = {}
	for element, _ in pairs(self.entries) do
		tbl[element] = element
	end
	return tbl
end

--- Iterates over each element of the set, the first time `func(e)`
--- for each element `e` there is returns true, this returns true
--- otherwise returns false.
--- @param func fun(element: any): boolean
--- @return boolean
function Set:any(func)
	for element, _ in pairs(self.entries) do
		if func(element) == true then return true end
	end
	return false
end

--- Iterates over each element of the set, the first time `func(e)`
--- for each element `e` there is returns non-true, this returns false,
--- otherwise returns true.
--- @param func fun(element: any): boolean
--- @return boolean
function Set:all(func)
	for element, _ in pairs(self.entries) do
		if func(element) ~= true then return false end
	end
	return true
end

--- Returns wheather the sets intersect. (share at least 1 common element)
--- @param other_set Set
--- @return boolean
function Set:intersects(other_set)
	local other_contains = function(e) return other_set:contains(e) end
	return self:any(other_contains)
end

--- Returns wheather the sets are disjointed or not. (share no common element)
--- This is the same as `not self:intersects(other_set)`
--- @param other_set any
--- @return boolean
function Set:is_disjointed_with(other_set)
	return not self:intersects(other_set)
end

--- Creates a new set consisting of elements both present in this set and
--- `other_set`.
--- @param other_set Set
--- @return Set
function Set:intersection(other_set)
	local mapper = function(e)
		if other_set:contains(e) then
			return e
		else
			return nil
		end
	end

	return self:mapped(mapper)
end

--- Creates a new set consisting of all the elements in this set and
--- `other_set`.
--- @param other_set Set
--- @return Set
function Set:union(other_set)
	local result = self:clone()
	local adder = function(e) result:push(e) end
	other_set:foreach(adder)
	return result
end

--- Returns wheather the set contains (contains all elements of or is
--- equal to) `smaller_set`.
--- @param smaller_set Set
--- @return boolean
function Set:contains_set(smaller_set)
	if #self < #smaller_set then return false end
	local self_contains = function(e) return self:contains(e) end
	return smaller_set:all(self_contains)
end

--- Returns wheather the set contains (contains all elements of)
--- `smaller_set` properly. (non-equally)
--- @param smaller_set Set
--- @return boolean
function Set:contains_proper_set(smaller_set)
	if #self <= #smaller_set then return false end
	local self_contains = function(e) return self:contains(e) end
	return smaller_set:all(self_contains)
end

--- Returns wheather the set is contained by (is a subset of)
--- `bigger_set`.
--- @param bigger_set Set
--- @return boolean
function Set:is_contained_by(bigger_set)
	return bigger_set:contains_set(self)
end

--- Returns wheather the set is contained by (is a subset of)
--- `bigger_set` properly. (non-equally)
--- @param bigger_set Set
--- @return boolean
function Set:is_contained_properly_by(bigger_set)
	return bigger_set:contains_proper_set(self)
end

--- Creates a new set consisting of elements in this set with the
--- elements of `rhs_set` removed from it.
--- @param rhs_set Set
--- @return Set
function Set:difference(rhs_set)
	local result = Set()
	local adder = function(e)
		if not rhs_set:contains(e) then
			result:push(e)
		end
	end

	self:foreach(adder)
	return result
end

--- Creates a new set consisting of elements in this is set and
--- `rhs_set` without the intersecting elements.
--- @param other_set Set
--- @return Set
function Set:sym_difference(other_set)
	local result = Set()

	local self_adder = function(e)
		if not other_set:contains(e) then
			result:push(e)
		end
	end
	self:foreach(self_adder)

	local rhs_adder = function(e)
		if not self:contains(e) then
			result:push(e)
		end
	end
	other_set:foreach(rhs_adder)

	return result
end

--- Returns the cartesian product (`lhs x rhs`) of sets
--- `lhs` and `rhs`.
--- @param rhs_set Set
--- @return Set
function Set:cross(rhs_set)
	local product = Set()

	for lele, _ in pairs(self.entries) do
		for rele, _ in pairs(rhs_set.entries) do
			product:push({ lele, rele })
		end
	end

	return product
end

--- Creates a set equal to the `set`. This is a shallow copy, meaning
--- inner tables are not copied over.
--- @param set Set
--- @return Set
function Set.cloned_from(set)
	local new_set = Set()
	for element in pairs(set.entries) do
		new_set.entries[element] = EXISTS
	end
	return new_set
end

--- Creates a new set equal to this set. This is a shallow copy,
--- meaning inner tables are not copied over.
--- @return Set
function Set:clone()
	return Set.cloned_from(self)
end

Class.formatter(Set,
	--- Formats the set to a string.
	--- @return string
	function(set)
		local items = {}
		for element in pairs(set.entries) do
			if type(element) == "table" then
				local titems = {}
				for _, v in ipairs(element) do
					table.insert(titems, tostring(v))
				end
				table.insert(items, "(" .. table.concat(titems, ", ") .. ")")
			else
				table.insert(items, tostring(element))
			end
		end

		return "{ " .. table.concat(items, ", ") .. " }"
	end)

Class.add_op(Set, function(lhs, rhs)
	return lhs:union(rhs)
end)

Class.sub_op(Set, function(lhs, rhs)
	return lhs:difference(rhs)
end)

Class.mul_op(Set, function(lhs, rhs)
	return lhs:cross(rhs)
end)

Class.eq_op(Set,
	--- Wheather sets `lhs` and `rhs` have the same elements
	--- @param lhs Set
	--- @param rhs Set
	--- @return boolean
	function(lhs, rhs)
		if #lhs ~= #rhs then return false end
		local self_contains = function(e) return lhs:contains(e) end
		return rhs:all(self_contains)
	end)

return Set
