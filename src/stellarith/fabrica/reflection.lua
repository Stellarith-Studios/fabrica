local table = require("stellarith.fabrica.extensions.table")

local dispatch = {}

--- Gets the constructor for the `class`. Returns `nil` if there isn't any.
--- `class` is not required to be created with this library, it can be a
--- table with a metatable.
--- @generic T
--- @param class T
--- @return (fun(...): T)?
function dispatch.get_constructor(class)
	local mt = getmetatable(class)
	if mt then
		local m_call = mt.__call
		if m_call then
			return function(...)
				m_call(class, ...)
			end
		end
	end
	return nil
end

--- Gets the destructor for the `class`. Returns `nil` if there isn't any.
--- `class` is not required to be created with this library, it can be a
--- table with a metatable.
--- @generic T
--- @param class T
--- @return (fun(...): T)?
function dispatch.get_destructor(class)
	local mt = getmetatable(class)
	if mt then
		local m_close = mt.__close
		if m_close then
			return function(...)
				m_close(class, ...)
			end
		end
	end
	return nil
end

--- Copies `class` and returns a new class with the same fields and
--- functions of `class`.
---
--- If `class` is too big this may lower performance significantly.
--- @generic T
--- @param class T
--- @return table
function dispatch.copy_class(class)
	local nc = table.copy(class)
	local mt = getmetatable(class)
	if mt then
		setmetatable(nc, mt)
	end
	return nc
end

return dispatch
