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
require("stellarith.fabrica.class")

--- A special list containing unique elements only once. Indexing
--- elements have a time complexity of `O(1)`.
---
--- Example:
--- ```
--- local set = Set(1, 2, 3, {1, 2})
--- local other = Set.from_list({1, 2})
--- assert(set:intersection(other):size() == 2)
--- ```
--- @class Set
--- A table of key value _pairs_ of this set where keys are the
--- elements and the values are all `true`.
---
--- **Note:** An element of a set can not be of nil value.
--- @field entries table<any, boolean>

local EXISTS = true

--- @overload fun(...: any): Set
Set = Class()

constructor(Set, function(...)
	local entries = {}
	for _, element in ipairs({ ... }) do
		entries[element] = EXISTS
	end
	return new(Set, { _entries = entries })
end)

--- @class Set
--- Creates a new set from the `list`. Uses `ipairs`
--- so only array-like elements will be included.
--- @field from_list fun(list: table): Set

--- Creates a new set from the `list`. Uses `ipairs`
--- so only array-like elements will be included.
--- @param list table
--- @return Set
function Set.from_list(list)
	local entries = {}
	for _, element in ipairs(list) do
		entries[element] = EXISTS
	end
	return new(Set, { _entries = entries })
end

--- @class Set
--- Checks if a certain `element` is added to this set.
--- @field contains fun(self: Set, element: any): boolean

--- Checks if a certain `element` is added to this set.
--- @param element any
--- @return boolean
function Set:contains(element)
	return self.entries[element] == EXISTS
end

--- @class Set
--- Adds a new element to the set
--- @field push fun(self: Set, element: any)

--- Adds a new element to the set
--- @param element any
function Set:push(element)
	if element == nil then return end
	self.entries[element] = EXISTS
end

--- @class Set
--- Removes an element from the set, if it exists.
--- @field remove fun(self: Set, element: any)

--- Removes an element from the set, if it exists.
--- @param element any
function Set:remove(element)
	if element == nil then return end
	self.entries[element] = nil
end

--- @class Set
--- Removes every element from the set. Doesn't destroy the actual set.
--- (Abandons the previous entry table, leaving the garbage collector to
--- deallocate it)
--- @field clear fun(self: Set)

--- Removes every element from the set. Doesn't destroy the actual set.
--- (Abandons the previous entry table, leaving the garbage collector to
--- deallocate it)
function Set:clear()
	self.entries = {}
end

--- @class Set
--- Returns the number of elements in the set.
--- @field size fun(self: Set)

--- Returns the number of elements in the set.
--- @return integer
function Set:size()
	local size = 0
	for _, _ in pairs(self.entries) do
		size = size + 1
	end
	return size
end

--- @class Set
--- Returns wheather this set is empty or not, identical to the value
--- of `self:size() < 1`.
--- @field is_empty fun(self: Set): boolean

--- Returns wheather this set is empty or not, identical to the value
--- of `self:size() < 1`.
--- @return boolean
function Set:is_empty()
	return self:size() < 1
end

--- @class Set
--- Returns a stateless iterator function over the elements of this
--- set to be used in a for loop.
---
--- Example:
--- ```
--- local set = Set(3, 5, "foo", "bar")
--- for element in set:iter() do
---     assert(set.entries[element])
--- end
--- ```
--- @field iter fun(self: Set): function, table

--- Returns a stateless iterator function over the elements of this
--- set to be used in a for loop.
---
--- Example:
--- ```
--- local set = Set(3, 5, "foo", "bar")
--- for element in set:iter() do
---     assert(set.entries[element])
--- end
--- ```
--- @return function
--- @return table<any, boolean>
function Set:iter()
	return next, self.entries
end

--- @class Set
--- Iterates over the elements of the set. Calls `func(e)` for each
--- element `e` there is.
--- @field foreach fun(self: Set, func: fun(element: any))

--- Iterates over the elements of the set. Calls `func(e)` for each
--- element `e` there is.
--- @param func fun(element: any)
function Set:foreach(func)
	for element, _ in pairs(self.entries) do
		func(element)
	end
end

--- @class Set
--- Iterates over the elements of the set, mapping each element to
--- the return value of `func(e)` for each element `e` there is.
--- @field map fun(self: Set, func: fun(element: any): any): Set

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

--- @class Set
--- Creates a new set iterating over the elements of the original
--- set, mapping each element to the return value of `func(e)`
--- for each element `e` there is.
--- @field mapped fun(self: Set, func: fun(element: any): any): Set

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

--- @class Set
--- Iterates over the elements of the set, evaluating `func(e)` for
--- each element `e` there is, if the result is `true`, keeps it in
--- the set otherwise removes it.
--- @field filter fun(self: Set, func: fun(element: any): boolean)

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

--- @class Set
--- Creates a new set iterating over the elements of the set, evaluating
--- `func(e)` for each element `e` there is, if the result is `true`,
--- adds it to the new set otherwise skips it.
--- @field filtered fun(self: Set, func: fun(element: any): boolean): Set

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

--- @class Set
--- Creates a table with keys consisting of elements of the set
--- and values generated by `value_generator(e)` for each element
--- `e` there is.
--- @field pairs fun(self: Set, value_generator: fun(element: any): any): table

--- Creates a table with keys consisting of elements of the set
--- and values generated by `value_generator(e)` for each element
--- `e` there is.
--- @param value_generator fun(element: any): any
--- @return table
function Set:pairs(value_generator)
	local table = {}
	for element, _ in pairs(self.entries) do
		table[element] = value_generator(element)
	end
	return table
end

--- @class Set
--- Creates a table with values consisting of elements of the set
--- and keys generated by `key_generator(e)` for each element
--- `e` there is.
--- @field kpairs fun(self: Set, key_generator: fun(element: any): any): table

--- Creates a table with values consisting of elements of the set
--- and keys generated by `key_generator(e)` for each element
--- `e` there is.
--- @param key_generator fun(element: any): any
--- @return table
function Set:kpairs(key_generator)
	local table = {}
	for element, _ in pairs(self.entries) do
		table[key_generator(element)] = element
	end
	return table
end

--- @class Set
--- Creates a table with values generated by `value_generator(e)`
--- and keys generated by `key_generator(e)`.
--- @field kvpairs fun(self: Set, key_generator: fun(element: any): any, value_generator: fun(element: any): any): table

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

--- @class Set
--- Creates a table with identical keys and values from the elements
--- of the set.
--- @field splat fun(self: Set): table

--- Creates a table with identical keys and values from the elements
--- of the set.
--- @return table
function Set:splat()
	local table = {}
	for element, _ in pairs(self.entries) do
		table[element] = element
	end
	return table
end

--- @class Set
--- Iterates over each element of the set, the first time `func(e)`
--- for each element `e` there is returns true, this returns true
--- otherwise returns false.
--- @field any fun(self: Set, func: fun(element: any): boolean): boolean

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

--- @class Set
--- Iterates over each element of the set, the first time `func(e)`
--- for each element `e` there is returns non-true, this returns false,
--- otherwise returns true.
--- @field all fun(self: Set, func: fun(element: any): boolean): boolean

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

--- @class Set
--- Returns wheather the sets intersect. (share at least 1 common element)
--- @field intersects fun(self: Set, other_set: Set): boolean

--- Returns wheather the sets intersect. (share at least 1 common element)
--- @param other_set Set
--- @return boolean
function Set:intersects(other_set)
	local other_contains = function(e) return other_set:contains(e) end
	return self:any(other_contains)
end

--- @class Set
--- Returns wheather the sets are disjointed or not. (share no common element)
--- This is the same as `not self:intersects(other_set)`
--- @field is_disjointed_with fun(self: Set, other_set: Set): boolean

--- Returns wheather the sets are disjointed or not. (share no common element)
--- This is the same as `not self:intersects(other_set)`
--- @param other_set any
--- @return boolean
function Set:is_disjointed_with(other_set)
	return not self:intersects(other_set)
end

--- @class Set
--- Creates a new set consisting of elements both present in this set and
--- `other_set`.
--- @field intersection fun(self: Set, other_set: Set): Set

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

--- @class Set
--- Creates a new set consisting of all the elements in this set and
--- `other_set`.
--- @field union fun(self: Set, other_set: Set): Set

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

--- @class Set
--- Returns wheather the set contains (contains all elements of or is
--- equal to) `smaller_set`.
--- @field contains_set fun(self: Set, smaller_set: Set): boolean

--- Returns wheather the set contains (contains all elements of or is
--- equal to) `smaller_set`.
--- @param smaller_set Set
--- @return boolean
function Set:contains_set(smaller_set)
	if self:size() < smaller_set:size() then return false end
	local self_contains = function(e) return self:contains(e) end
	return smaller_set:all(self_contains)
end

--- @class Set
--- Returns wheather the set contains (contains all elements of)
--- `smaller_set` properly. (non-equally)
--- @field contains_proper_set fun(self: Set, smaller_set: Set): boolean

--- Returns wheather the set contains (contains all elements of)
--- `smaller_set` properly. (non-equally)
--- @param smaller_set Set
--- @return boolean
function Set:contains_proper_set(smaller_set)
	if self:size() <= smaller_set:size() then return false end
	local self_contains = function(e) return self:contains(e) end
	return smaller_set:all(self_contains)
end

--- @class Set
--- Returns wheather the set is contained by (is a subset of)
--- `bigger_set`.
--- @field is_contained_by fun(self: Set, bigger_set: Set): boolean

--- Returns wheather the set is contained by (is a subset of)
--- `bigger_set`.
--- @param bigger_set Set
--- @return boolean
function Set:is_contained_by(bigger_set)
	return bigger_set:contains_set(self)
end

--- @class Set
--- Returns wheather the set is contained by (is a subset of)
--- `bigger_set` properly. (non-equally)
--- @field is_contained_properly_by fun(self: Set, bigger_set: Set): boolean

--- Returns wheather the set is contained by (is a subset of)
--- `bigger_set` properly. (non-equally)
--- @param bigger_set Set
--- @return boolean
function Set:is_contained_properly_by(bigger_set)
	return bigger_set:contains_proper_set(self)
end

--- @class Set
--- Creates a new set consisting of elements in this set with the
--- elements of `rhs_set` removed from it.
--- @field difference fun(lhs: Set, rhs: Set): Set

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

--- @class Set
--- Creates a new set consisting of elements in this is set and
--- `rhs_set` without the intersecting elements.
--- @field sym_difference fun(self: Set, other_set: Set): Set

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

--- @class Set
--- Returns the cartesian product (`lhs x rhs`) of sets
--- `lhs` and `rhs`.
--- @field cross fun(lhs: Set, rhs: Set): Set

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

-- Trait: Clone

--- @class Set
--- Creates a set equal to the `set`. This is a shallow copy, meaning
--- inner tables are not copied over.
--- @field cloned_from fun(set: Set): Set

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

--- @class Set
--- Creates a new set equal to this set. This is a shallow copy,
--- meaning inner tables are not copied over.
--- @field clone fun(self: Set): Set

--- Creates a new set equal to this set. This is a shallow copy,
--- meaning inner tables are not copied over.
--- @return Set
function Set:clone()
	return Set.cloned_from(self)
end

-- Trait: Formatter

--- @class Set
--- Formats the set to a string.
--- @field tostring fun(self: Set): string

--- Formats the set to a string.
--- @return string
function Set:tostring()
	local items = {}
	for element in pairs(self.entries) do
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
end

--- Formats the set to a string.
--- @return string
function Set:__tostring() return self:tostring() end

-- Trait: Operators

function Set:__add(rhs) return self:union(rhs) end

function Set:__sub(rhs) return self:difference(rhs) end

function Set:__div(rhs) return self:difference(rhs) end

function Set:__mul(rhs) return self:cross(rhs) end

--- @class Set
--- Returns wheather the set equals (has the same elements)
--- `other_set`.
--- @field eq fun(lhs: Set, rhs: Set): boolean

--- Returns wheather the set equals (has the same elements)
--- `other_set`.
--- @param other_set Set
--- @return boolean
function Set:eq(other_set)
	if self:size() ~= other_set:size() then return false end
	local self_contains = function(e) return self:contains(e) end
	return other_set:all(self_contains)
end

function Set:__eq(rhs) return self:eq(rhs) end

return Set
