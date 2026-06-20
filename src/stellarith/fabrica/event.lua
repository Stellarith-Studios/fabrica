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
local Class = require("stellarith.fabrica.class")

--- @class Event.CallerId: integer

--- A (un)subscribable event that calls a list of functions when pushed.
--- @class Event
--- List of functions called when this event is pushed.
--- @field callbacks fun(...: any)[]
--- @overload fun(): Event
local Event = Class()

Class.constructor(Event, function()
	return Class.new(Event, {
		_callbacks = {},
		_next_id = 0,
	})
end)

--- Adds the `callback` to the called functions when this event is pushed.
---
--- Returns the caller id.
--- @param callback fun(...: any)
--- @return Event.CallerId
function Event:subscribe(callback)
	self.next_id = self.next_id + 1
	self.callbacks[self.next_id] = callback
	return self.next_id
end

--- Removes the callback with the specific `caller_id` from the list of
--- functions called when this event is pushed.
---
--- Returns wheather the `caller_id` existed in the event or not.
--- @param caller_id Event.CallerId
--- @return boolean
function Event:unsubscribe(caller_id)
	local before = self.callbacks[caller_id]
	self.callbacks[caller_id] = nil
	return before ~= nil
end

--- Emits the event, calling all callback functions with the parameters
--- `...`.
--- @param ... any
function Event:push_call(...)
	for _, func in ipairs(self.callbacks) do
		func(...)
	end
end

return Event
