local PRIVATE_PREFIX = "_"
local GET_PREFIX = "get_"
local SET_PREFIX = "set_"

--- @alias class table

local function to_private_name(property_name)
	return PRIVATE_PREFIX .. property_name
end

--- Rawgets the given `key`'s private version' on instance `instance` properly without indexing the
--- instance table, intended to be used on a getter method.
--- @param instance unknown
--- @param public_key string
function rawgetp(instance, public_key)
	return rawget(instance, to_private_name(public_key))
end

local function standard_getter(class, instance, key)
	local top_level_declaration = rawget(class, key)
	if top_level_declaration then
		return top_level_declaration
	end

	local getter_function = rawget(class, GET_PREFIX .. key)
	if getter_function then
		return getter_function(instance)
	end
	return rawgetp(instance, key)
end

local function getterize(class)
	class.__index = function(instance, key) return standard_getter(class, instance, key) end
end

--- Rawsets the given `key`'s private version to `value` on instance `instance` properly without
--- newindexing the instance table, intended to be used on a setter method.
--- @param instance unknown
--- @param public_key string
--- @param value? any
function rawsetp(instance, public_key, value)
	rawset(instance, to_private_name(public_key), value)
end

local function standard_setter(class, instance, key, value)
	local setter_function = rawget(class, SET_PREFIX .. key)
	if setter_function then
		setter_function(instance, value)
	else
		rawsetp(instance, key, value)
	end
end

local function setterize(class)
	class.__newindex = function(instance, key, value) standard_setter(class, instance, key, value) end
end

--- Creates a class. A class is a metatable *and* indextable for instances of that class to be
--- created, containing definitions for fields and methods.
--- @return class
function Class()
	local class = {}
	getterize(class)
	setterize(class)
	return class
end

--- Creates the constructor for the given `class`.
function constructor(class, func)
	local mt = getmetatable(class) or {}
	-- since class constructors dont need the class to be provided in the first argument let's
	-- pipe it to an unused argument:
	mt.__call = function(_, ...)
		return func(...)
	end
	setmetatable(class, mt)
end

--- Creates an instance of the given `class`, imports the `defaults` table if set, remains empty
--- otherwise. `class` is required to be created using `Class()`
--- @param class class | any
--- @param defaults? table
--- @return unknown
function new(class, defaults)
	local instance = defaults or {}
	setmetatable(instance, class)
	return instance
end

local READONLY_ERROR = "Trying to set readonly field %s: %s"
local READONLY_FUNCTION = function(t, v) error(READONLY_ERROR:format(tostring(t), tostring(v))) end

--- Macro to mark all field names provided on the `class` as readonly, trying to set them will
--- result in an error.
--- @param class class | any class that owns fields to be marked readonly
--- @param ... string fields to be marked readonly
function readonly(class, ...)
	for _, field in ipairs({ ... }) do
		class["set_" .. field] = READONLY_FUNCTION
	end
end

--- Macro to define the same setter for all field names provided on the `class`.
--- @param class class | any
--- @param setter function<table, any>
--- @param ... string
function uniform_setter(class, setter, ...)
	for _, field in ipairs({ ... }) do
		class["set_" .. field] = function(t, value) setter(t, field, value) end
	end
end

return Class
