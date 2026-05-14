-- -----------------------------------------------------------------
-- Fabrica
-- table.lua
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
--- Shallow duplicates a table, that is this table's key value pairs
--- are copied but any table value still points to the same table.
--- @param t table
--- @return table
function table.clone(t)
	local nt = {}
	for k, v in pairs(t) do
		nt[k] = v
	end
	return nt
end

--- @param t table
--- @param iterator integer
--- @param iteration_cap integer
--- @return table
local function table_capped_copy(t, iterator, iteration_cap)
	if iterator > iteration_cap then
		return t
	end
	local nt = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			v = table_capped_copy(v, iterator + 1, iteration_cap)
		end
		nt[k] = v
	end
	return nt
end

--- @param t table
--- @return table
local function table_uncapped_copy(t)
	local nt = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			v = table_uncapped_copy(v)
		end
		nt[k] = v
	end
	return nt
end

--- Deep copies a table, that is this table's key value pairs are
--- copied together with any table value until `iteration_cap` is
--- reached.
--- @param t table
--- @return table
function table.copy(t, iteration_cap)
	if iteration_cap then
		return table_capped_copy(t, 0, iteration_cap)
	else
		return table_uncapped_copy(t)
	end
end

--- Maps the return values of `func(k)` for each key `k` there is
--- on the table `t`, changes values in-place.
--- @param t table
--- @param func fun(key: any): any
function table.map(t, func)
	for k, _ in pairs(t) do
		t[k] = func(k)
	end
end

--- Maps the return values of `func(k)` for each key `k` there is
--- on the table `t`, creates a new table with the new pairs.
--- @param t any
--- @param func any
--- @return table
function table.mapped(t, func)
	local nt = {}
	for k, _ in pairs(t) do
		nt[k] = func(k)
	end
	return nt
end

--- Sets every key's value to `v` on the table `t`.
--- @param t table
--- @param v any
function table.splat(t, v)
	for k, _ in pairs(t) do
		t[k] = v
	end
end

--- Creates a new table setting every key's value to `v` on the
--- table `t`.
--- @param t table
--- @param v any
--- @return table
function table.splatted(t, v)
	local nt = {}
	for k, _ in pairs(t) do
		nt[k] = v
	end
	return nt
end

--- Adds all key value pairs in table `dominant` to table `other`.
--- @param dominant table
--- @param other table
function table.combine(dominant, other)
	for k, v in pairs(dominant) do
		other[k] = v
	end
end

return table
