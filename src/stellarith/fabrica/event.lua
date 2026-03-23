require("stellarith.fabrica.class")

--- @class Event
--- @field callbacks table<fun(...: any)>

Event = Class()

constructor(Event, function()
	return new(Event, {
		_callbacks = {},
	})
end)

function Event:subscribe(callback)
	table.insert(self.callbacks, callback)
	return #self.callbacks
end

function Event:unsubscribe(caller_id)
	table.remove(self.callbacks, caller_id)
end

function Event:push_call(...)
	for _, func in ipairs(self.callbacks) do
		func(...)
	end
end
