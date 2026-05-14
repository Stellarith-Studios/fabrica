-- -----------------------------------------------------------------
-- Fabrica
-- event.lua
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

--- A (un)subscribable event that calls a list of functions when pushed.
--- @class Event
--- List of functions called when this event is pushed.
--- @field callbacks table<fun(...: any)>

--- @class Event
--- Adds the `callback` to the called functions when this event is pushed.
--- Returns the caller id.
--- @field subscribe fun(self: Event, callback: fun(...: any)): integer

--- @class Event
--- Removes the callback with the specific `caller_id` from the list of
--- functions called when this event is pushed.
--- @field unsubscribe fun(self: Event, caller_id: integer)

--- @class Event
--- Emits the event, calling all callback functions with the parameters
--- `...`.
--- @field push_call fun(self: Event, ...: any)

--- Constructs a new Event.
--- @overload fun(): Event
Event = Class()

constructor(Event, function()
	return new(Event, {
		_callbacks = {},
	})
end)

--- Adds the `callback` to the called functions when this event is pushed.
--- Returns the caller id.
--- @param callback fun(...: any)
--- @return integer
function Event:subscribe(callback)
	table.insert(self.callbacks, callback)
	return #self.callbacks
end

--- Removes the callback with the specific `caller_id` from the list of
--- functions called when this event is pushed.
--- @param caller_id integer
function Event:unsubscribe(caller_id)
	table.remove(self.callbacks, caller_id)
end

--- --- Emits the event, calling all callback functions with the parameters
--- `...`.
--- @param ... any
function Event:push_call(...)
	for _, func in ipairs(self.callbacks) do
		func(...)
	end
end

return Event
