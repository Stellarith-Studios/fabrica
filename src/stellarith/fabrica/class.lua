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
local table = require("stellarith.fabrica.extensions.table")

local PRIVATE_PREFIX = "_"
local GET_PREFIX = "get_"
local SET_PREFIX = "set_"

--- A class is a metatable *and* indextable for instances of that class to be
--- created, containing definitions for fields and methods.
--- @generic B
--- @generic T
--- @overload fun(base: B?): T
local dispatch = {}

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

--- @class Class
--- @field _base Class?

--- Returns the base class of `class` or `nil`.
--- @generic T, B
--- @param class T
--- @return B?
function dispatch.super(class)
	---@cast class Class
	return class._base
end

local m_get_field_name = dispatch.get_field_name
local m_get_getter_name = dispatch.get_getter_name
local m_get_setter_name = dispatch.get_setter_name
local m_super = dispatch.super

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

	local base = m_super(class)
	if base then
		local base_static_declaration = rawget(base, key)
		if base_static_declaration then
			return base_static_declaration
		end

		local base_getter_function = rawget(base, getter_name)
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
		local base = m_super(class)
		if base then
			local base_setter_function = rawget(base, setter_name)
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
--- @generic B, T
--- @param base B
--- @return T
local function create_class(base)
	local class = {
		_base = base,
	}
	if base then
		setmetatable(class, table.clone(getmetatable(base)))
		child_class_getterize(class, base)
	end
	getterize(class)
	setterize(class)
	return class
end

--- Creates the constructor for the given `class`.
--- @generic T
--- @param class T
--- @param func fun(...): T
function dispatch.constructor(class, func)
	local mt = getmetatable(class) or {}
	-- since class constructors dont need the class to be provided in the first
	-- argument let's pipe it to an unused argument:
	mt.__call = function(_, ...)
		return func(...)
	end
	setmetatable(class --[[@as table]], mt)
end

--- Creates the destructor for the given `class`.
--- @generic T
--- @param class T
--- @param func fun(err: any)
function dispatch.destructor(class, func)
	local mt = getmetatable(class) or {}
	mt.__close = function(_, err)
		return func(err)
	end
	setmetatable(class --[[@as table]], mt)
end

--- Defines a metatable entry with `name` for `class`.
--- @generic T
--- @param class T
--- @param name string
--- @param func function
function dispatch.operator(class, name, func)
	local mt = getmetatable(class) or {}
	mt[name] = func
	setmetatable(class, mt)
end

local m_operator = dispatch.operator

--- Defines the `+` (addition) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(lhs: any, rhs: any): any
function dispatch.add_op(class, func)
	m_operator(class, "__add", func)
end

--- Defines the `-` (subtraction) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(lhs: any, rhs: any): any
function dispatch.sub_op(class, func)
	m_operator(class, "__sub", func)
end

--- Defines the `*` (multiplication) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(lhs: any, rhs: any): any
function dispatch.mul_op(class, func)
	m_operator(class, "__mul", func)
end

--- Defines the `/` (division) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(lhs: any, rhs: any): any
function dispatch.div_op(class, func)
	m_operator(class, "__div", func)
end

--- Defines the `-v` (unary minus) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(lhs: any, rhs: any): any
function dispatch.unm_op(class, func)
	m_operator(class, "__unm", func)
end

--- Defines the `%` (modulo) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(lhs: any, rhs: any): any
function dispatch.mod_op(class, func)
	m_operator(class, "__mod", func)
end

--- Defines the `^` (power) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(lhs: any, rhs: any): any
function dispatch.pow_op(class, func)
	m_operator(class, "__pow", func)
end

--- Defines the `//` (integer division) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(lhs: any, rhs: any): any
function dispatch.idiv_op(class, func)
	m_operator(class, "__idiv", func)
end

--- Defines the `==` (equals) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(lhs: any, rhs: any): boolean
function dispatch.eq_op(class, func)
	m_operator(class, "__eq", func)
end

--- Defines the `<` (less than) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(lhs: any, rhs: any): boolean
function dispatch.lt_op(class, func)
	m_operator(class, "__lt", func)
end

--- Defines the `<=` (less than or equal to) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(lhs: any, rhs: any): boolean
function dispatch.le_op(class, func)
	m_operator(class, "__le", func)
end

--- Defines the `..` (concatination) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(lhs: any, rhs: any): string
function dispatch.concat_op(class, func)
	m_operator(class, "__concat", func)
end

--- Defines the `#` (length) operator for `class`.
--- @generic T
--- @param class T
--- @param func fun(inst: T): integer
function dispatch.len_op(class, func)
	m_operator(class, "__len", func)
end

--- Defines the `tostring(v)` function for `class`.
--- @generic T
--- @param class T
--- @param func fun(inst: T): string
function dispatch.formatter(class, func)
	m_operator(class, "__tostring", func)
end

--- Defines the `pairs(v)` function for `class`.
--- @generic T
--- @param class T
--- @param func fun(inst: T): function, ...: any
function dispatch.iterator(class, func)
	m_operator(class, "__pairs", func)
end

--- Creates an instance of the given `class`, imports the `defaults` table if
--- set, remains empty otherwise. `class` is not required to be created using
--- `Class()` and can be a generic metatable.
--- @generic T
--- @param class `T`
--- @param defaults? table
--- @return T
function dispatch.new(class, defaults)
	local instance = defaults or {}
	setmetatable(instance, class --[[@as metatable]])
	return instance
end

--- This field is readonly.
--- @class readonly: any

local READONLY_ERROR = "Trying to set readonly field %s: %s"
local READONLY_FUNCTION = function(t, v) error(READONLY_ERROR:format(tostring(t), tostring(v))) end

--- Macro to mark all field names provided on the `class` as readonly, trying to set them will
--- result in an error.
--- @generic T
--- @param class T class that owns fields to be marked readonly
--- @param ... string fields to be marked readonly
function dispatch.readonly(class, ...)
	for _, field in ipairs({ ... }) do
		class["set_" .. field] = READONLY_FUNCTION
	end
end

--- Macro-like implementation to define the same setter for all field names
--- provided on the `class`.
--- @generic T
--- @param class T
--- @param setter fun(instance: T, field: string, value: any)
--- @param ... string
function dispatch.uniform_setter(class, setter, ...)
	for _, field in ipairs({ ... }) do
		class["set_" .. field] = function(t, value) setter(t, field, value) end
	end
end

--- Macro-like implementation to define the same getter for all field names
--- provided on the `class`.
--- @generic T
--- @param class T
--- @param getter fun(instance: T, field: string)
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
