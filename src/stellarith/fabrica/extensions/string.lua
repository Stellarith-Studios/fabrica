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
