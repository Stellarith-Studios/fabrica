require("stellarith.fabrica.class")
require("stellarith.fabrica.logging.ansiformat")

--- A custom prefixed logger.
--- @class Logger
--- Should the logger print or not.
--- @field silent boolean
--- The prefix attached to the logger.
--- @field prefix string
--- @field formatter AnsiFormat
--- @field history_enabled boolean

--- Constructs a new `Logger`.
--- @overload fun(prefix: string, format: AnsiFormat?, silent: boolean?, enable_history: boolean?): Logger
Logger = Class()

constructor(Logger, function(prefix, formatter, silent, enable_history)
	if silent == nil then
		silent = false
	end

	if enable_history ~= false then
		enable_history = true
	end

	return new(Logger, {
		_silent = silent,
		_prefix = prefix,
		_formatter = formatter or AnsiFormat.regular(),
		_history_enabled = enable_history ~= false,
		_history = {}
	})
end)

--- @class Logger
--- Returns wheather the logger is able to print messages.
--- @field is_silent fun(self: Logger): boolean

--- Returns wheather the logger is able to print messages.
function Logger:is_silent()
	return self.silent
end

--- @class Logger
--- Mutes the logger, disabling message printing.
--- @field mute fun(self: Logger)

--- Mutes the logger, disabling message printing.
function Logger:mute()
	self.silent = true
end

--- @class Logger
--- Unmutes the logger, enabling message printing.
--- @field unmute fun(self: Logger)

--- Unmutes the logger, enabling message printing.
function Logger:unmute()
	self.silent = false
end

--- @class Logger
--- Enables the logging history, recording every message
--- dispatched.
--- @field enable_history fun(self: Logger)

--- Enables the logging history, recording every message
--- dispatched.
function Logger:enable_history()
	self.history_enabled = true
end

--- @class Logger
--- Disables the logging history, stopping recording every
--- message dispatched.
--- @field disable_history fun(self: Logger)

--- Disables the logging history, stopping recording every
--- message dispatched.
function Logger:disable_history()
	self.history_enabled = false
end

--- @class Logger
--- Clears the logging history.
--- @field clear_history fun(self: Logger)

--- Clears the logging history.
function Logger:clear_history()
	self.history = {}
end

--- Calls `func(t, h)` for each history time `t` and message `h`
--- there is.
--- @param func fun(time: integer, history: string)
function Logger:foreach_history(func)
	for _, history in ipairs(self.history) do
		func(history.time, history.content)
	end
end

--- @class Logger
--- Prints the whole history of recorded messages with timestamps.
--- @field print_history fun(self: Logger)

--- Prints the whole history of recorded messages with timestamps.
function Logger:print_history()
	print("History of logger [" .. self.prefix .. "]")
	self:foreach_history(function(t, h)
		local line = "[" .. tostring(t) .. "] " .. h
		print(line)
	end)
end

--- @class Logger
--- Dispatches the message with the prefix of the logger, records
--- the message and the time it was sent in `history` if the
--- logger has `history_enabled` set to true, and prints the message
--- if the logger is not `silent`.
--- @field print fun(self: Logger, ...: any)

--- Dispatches the message with the prefix of the logger, records
--- the message and the time it was sent in `history` if the
--- logger has `history_enabled` set to true, and prints the message
--- if the logger is not `silent`.
--- @param ... any
function Logger:print(...)
	local line = tostring(...)
	if self.history_enabled == true then
		--- @type number
		local current
		if time and time.now then
			current = time.now()
		else
			current = os.clock()
		end
		local history = {
			time = current,
			content = line,
		}
		table.insert(self.history, history)
	end

	if not self.silent then
		print(self.formatter:format("[" .. self.prefix .. "]") .. " " .. line)
	end
end

--- @class Logger
--- Dispatches the message with the prefix of the logger, records
--- the message and the time it was sent in `history` if the
--- logger has `history_enabled` set to true, and prints the message
--- if the logger is not `silent`.
--- @field log fun(self: Logger, ...: any)

--- Dispatches the message with the prefix of the logger, records
--- the message and the time it was sent in `history` if the
--- logger has `history_enabled` set to true, and prints the message
--- if the logger is not `silent`.
--- @param ... any
function Logger:log(...)
	return self:print(...)
end

return Logger
