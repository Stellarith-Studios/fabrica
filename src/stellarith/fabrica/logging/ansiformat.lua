-- -----------------------------------------------------------------
-- Fabrica
-- ansiformat.lua
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

local function ansi(value)
	return string.char(27) .. '[' .. tostring(value) .. 'm'
end

--- A struct containing ANSI foreground and background colors used to
--- format the terminal message.
--- @class AnsiFormat
--- Foreground color of the ANSI formatter.
--- @field fg AnsiFormat.Color
--- Background color of the ANSI formatter.
--- @field bg AnsiFormat.Color
--- Intensity of the ANSI text.
--- @field intensity AnsiFormat.ColorIntensity
--- Wheather the text is underscored.
--- @field underscore boolean
--- Wheather the text periodically blinks or not.
--- @field blink boolean
--- Wheather the text is in reverse or not.
--- @field reverse boolean
--- Wheather the text is hidden or not.
--- @field hidden boolean

--- Constructs a new `AnsiFormat`.
--- @overload fun(fg: AnsiFormat.Color?, bg: AnsiFormat.Color?, intensity: AnsiFormat.ColorIntensity?, underscore: boolean?, blink: boolean?, reverse: boolean?, hidden: boolean?): AnsiFormat
local AnsiFormat = Class()

--- @enum AnsiFormat.Color
AnsiFormat.Color = {
	REGULAR = 0,
	BLACK = 30,
	RED = 31,
	GREEN = 32,
	YELLOW = 33,
	BLUE = 34,
	MAGENTA = 35,
	CYAN = 36,
	WHITE = 37,
}

local fmt_reset = ansi(AnsiFormat.Color.REGULAR)

--- @enum AnsiFormat.ColorIntensity
AnsiFormat.ColorIntensity = {
	REGULAR = 0,
	BRIGHT = 1,
	DIM = 2,
}

Class.constructor(AnsiFormat, function(fg, bg, intensity, underscore, blink, reverse, hidden)
	return Class.new(AnsiFormat, {
		_fg = fg or AnsiFormat.Color.REGULAR,
		_bg = bg or AnsiFormat.Color.REGULAR,
		_intensity = intensity or AnsiFormat.ColorIntensity.REGULAR,
		_underscore = underscore == true,
		_blink = blink == true,
		_reverse = reverse == true,
		_hidden = hidden == true,
	})
end)

--- Constructs a new `AnsiFormat` with regular properties.
--- @return AnsiFormat
function AnsiFormat.regular()
	return AnsiFormat()
end

--- Formats the string with this `AnsiFormat`'s properties.
--- @param s string
--- @return string
function AnsiFormat:format(s)
	local prefix = ansi(self.fg)
	if self.bg ~= AnsiFormat.Color.REGULAR then
		prefix = prefix .. ansi(self.bg + 10)
	end
	if self.intensity ~= AnsiFormat.ColorIntensity.REGULAR then
		prefix = prefix .. ansi(self.intensity)
	end
	if self.underscore then
		prefix = prefix .. ansi(4)
	end
	if self.blink then
		prefix = prefix .. ansi(5)
	end
	if self.reverse then
		prefix = prefix .. ansi(7)
	end
	if self.hidden then
		prefix = prefix .. ansi(8)
	end

	return prefix .. s .. fmt_reset
end

return AnsiFormat
