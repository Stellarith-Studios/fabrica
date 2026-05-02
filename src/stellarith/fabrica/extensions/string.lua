-- -----------------------------------------------------------------
-- Fabrica
-- string.lua
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
--   - Yarkın Saatçi (spigbop)
-- -----------------------------------------------------------------
--- Returns wheather the string `s` begins with the string `b`.
--- @param s string
--- @param b string
--- @return boolean
function string.begins_with(s, b)
	local begin_sub = s:sub(1, b:len())
	return begin_sub == b
end

--- Returns wheather the string `s` ends with the string `e`.
--- @param s string
--- @param e string
--- @return boolean
function string.ends_with(s, e)
	local len = s:len()
	local end_sub = s:sub(len - e:len() + 1, len)
	return end_sub == e
end

--- Looks for any match of `pattern` (see [§6.4.1](https://www.lua.org/manual/5.4/manual.html#6.4.1))
--- in the string `s`.
--- @param s string
--- @param pattern string
--- @param init integer? the index to start looking at.
--- @param plain boolean? wheather `pattern` should be treated as plain text or not.
--- @return boolean
function string.contains(s, pattern, init, plain)
	local start = s:find(pattern, init, plain)
	return start ~= nil
end

--- comment
--- @param s string
--- @return string
function string.snake_case(s)
	local res, _ = s:lower():gsub(" ", "_")
	return res
end

return string
