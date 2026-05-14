-- -----------------------------------------------------------------
-- Fabrica
-- fun.lua
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
fun = fun or {}

--- Clones a function invalidating all upvalue references. May return `nil` if the function could not be cloned.
--- @param f function function to be cloned
--- @return function? clone
--- @return string? err clone error message
function fun.clone(f)
	local ok, dumped = pcall(string.dump, f)
	if not ok then
		return nil, dumped
	end

	return load(dumped)
end

--- Copies a function with all upvalues. May return `nil` if the function could not be copied.
--- @param f function function to be copied
--- @return function? copy
--- @return string? copy error message
function fun.copy(f)
	local copy, err = fun.clone(f)

	if not copy then
		return nil, err
	end

	local i = 1
	while true do
		local name, _ = debug.getupvalue(f, i)
		if not name then break end
		debug.upvaluejoin(copy, i, f, i)
		i = i + 1
	end

	return copy
end
