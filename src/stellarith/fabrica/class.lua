-- -----------------------------------------------------------------
-- Fabrica
-- class.lua
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
local PRIVATE_PREFIX = "_"
local GET_PREFIX = "get_"
local SET_PREFIX = "set_"

--- @overload fun(base: class?): class_table
local dispatch = {}

--- @alias class_table table
--- @alias class class_table | function

--- Returns the private name for the field with name `field`. This will be used
--- to provide proper getter functionality.
--- @param field string
--- @return string
function dispatch.get_field_name(field)
	return PRIVATE_PREFIX .. field
end

--- Returns the getter method name for the field with name `field`.
--- @param field string
--- @return string
function dispatch.get_getter_name(field)
	return GET_PREFIX .. field
end

--- Returns the setter method name for the field with name `field`.
--- @param field string
--- @return string
function dispatch.get_setter_name(field)
	return SET_PREFIX .. field
end

local m_get_field_name = dispatch.get_field_name
local m_get_getter_name = dispatch.get_getter_name
local m_get_setter_name = dispatch.get_setter_name

--- Rawgets the given `key`'s private version' on instance `instance` properly
--- without indexing the instance table, intended to be used on a getter method.
--- @param instance unknown
--- @param public_key string
function dispatch.raw_get_field(instance, public_key)
	return rawget(instance, m_get_field_name(public_key))
end

local function standard_getter(class, instance, key)
	local static_declaration = rawget(class, key)
	if static_declaration then
		return static_declaration
	end

	local getter_name = m_get_getter_name(key)
	local getter_function = rawget(class, getter_name)
	if getter_function then
		return getter_function(instance)
	end

	local m_base = class.base
	if m_base then
		local base_static_declaration = rawget(m_base, key)
		if base_static_declaration then
			return base_static_declaration
		end

		local base_getter_function = rawget(m_base, getter_name)
		if base_getter_function then
			return base_getter_function(instance)
		end
	end

	return dispatch.raw_get_field(instance, key)
end

local function getterize(class)
	class.__index = function(instance, key)
		return standard_getter(class, instance, key)
	end
end

--- Rawsets the given `key`'s private version to `value` on instance `instance` properly without
--- newindexing the instance table, intended to be used on a setter method.
--- @param instance unknown
--- @param public_key string
--- @param value? any
function dispatch.raw_set_field(instance, public_key, value)
	rawset(instance, m_get_field_name(public_key), value)
end

local function standard_setter(class, instance, key, value)
	local setter_name = m_get_setter_name(key)
	local setter_function = rawget(class, setter_name)
	if setter_function then
		setter_function(instance, value)
	else
		local m_base = class.base
		if m_base then
			local base_setter_function = rawget(m_base, setter_name)
			base_setter_function(instance, value)
		else
			dispatch.raw_set_field(instance, key, value)
		end
	end
end

local function setterize(class)
	class.__newindex = function(instance, key, value)
		standard_setter(class, instance, key, value)
	end
end

local function standard_child_class_getter(class, base, key)
	local override = rawget(class, key)
	if override then
		return override
	end

	return rawget(base, key)
end

local function child_class_getterize(class, base)
	local mt = getmetatable(class) or {}
	mt.__index = function(_, key)
		return standard_child_class_getter(class, base, key)
	end
	setmetatable(class, mt)
end

--- Creates a class. A class is a metatable *and* indextable for instances of
--- that class to be created, containing definitions for fields and methods.
--- @param base class?
--- @return class_table
local function create_class(base)
	local class = {
		base = base,
	}
	if base then
		child_class_getterize(class, base)
	end
	getterize(class)
	setterize(class)
	return class
end

--- Creates the constructor for the given `class`.
--- @generic T
--- @param class class_table | class
--- @param func fun(...): T
function dispatch.constructor(class, func)
	local mt = getmetatable(class) or {}
	-- since class constructors dont need the class to be provided in the first
	-- argument let's pipe it to an unused argument:
	mt.__call = function(_, ...)
		return func(...)
	end
	setmetatable(class --[[@as class_table]], mt)
end

--- Creates the destructor for the given `class`.
function dispatch.destructor(class, func)
	local mt = getmetatable(class) or {}
	mt.__close = function(_, ...)
		return func(...)
	end
	setmetatable(class, mt)
end

--- Creates an instance of the given `class`, imports the `defaults` table if
--- set, remains empty otherwise. `class` is not required to be created using
--- `Class()` and can be a generic metatable.
--- @generic T
--- @param class class_table | class
--- @param defaults? table
--- @return T
function dispatch.new(class, defaults)
	local instance = defaults or {}
	setmetatable(instance, class --[[@as class_table]])
	return instance
end

--- This field is readonly.
--- @class readonly: any

local READONLY_ERROR = "Trying to set readonly field %s: %s"
local READONLY_FUNCTION = function(t, v) error(READONLY_ERROR:format(tostring(t), tostring(v))) end

--- Macro to mark all field names provided on the `class` as readonly, trying to set them will
--- result in an error.
--- @param class class class that owns fields to be marked readonly
--- @param ... string fields to be marked readonly
function dispatch.readonly(class, ...)
	for _, field in ipairs({ ... }) do
		class["set_" .. field] = READONLY_FUNCTION
	end
end

--- Macro to define the same setter for all field names provided on the `class`.
--- @param class class
--- @param setter fun(t: table, field: string, value: any)
--- @param ... string
function dispatch.uniform_setter(class, setter, ...)
	for _, field in ipairs({ ... }) do
		class["set_" .. field] = function(t, value) setter(t, field, value) end
	end
end

--- Macro to define the same getter for all field names provided on the `class`.
--- @param class class
--- @param getter fun(t: table, field: string)
--- @param ... string
function dispatch.uniform_getter(class, getter, ...)
	for _, field in ipairs({ ... }) do
		class["get_" .. field] = function(t) getter(t, field) end
	end
end

setmetatable(dispatch --[[@as table]], {
	__call = function(t, base)
		return create_class(base)
	end
})

return dispatch
