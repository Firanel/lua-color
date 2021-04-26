--- Lua color library
--
-- Convert and manipulate color values.
--
-- All values are in [0,1], unless otherwise specified.



require "lua-color.util"
local class = require "lua-color.util.class"




-- Utils


local function hcm_to_rgb(h, c, m)
  local r, g, b = 0, 0, 0

  h = h * 6
  local x = c * (1 - math.abs(h % 2 - 1))

  if h <= 1 then
    r, g, b = c, x, 0
  elseif h <= 2 then
    r, g, b = x, c, 0
  elseif h <= 3 then
    r, g, b = 0, c, x
  elseif h <= 4 then
    r, g, b = 0, x, c
  elseif h <= 5 then
    r, g, b = x, 0, c
  elseif h <= 6 then
    r, g, b = c, 0, x
  end

  return r + m, g + m, b + m
end



-- Color


--- Color class
--
-- @param value Color in hex notation
--              or as {r=, g=, b=}
--              or as {h=, s=, v=}
--              or as {h=, s=, l=}
--              or another Color
--
-- @return Color
local Color = class(function (this, value)
  this.__is_color = true

  if value then
    this:set(value)
  else
    this.r = 0
    this.g = 0
    this.b = 0
  end
end)

--- Clone color
function Color:clone()
  return Color(self)
end

--- Set color to value
--
-- @param value Color in hex notation
--              or as {r=, g=, b=}
--              or as {h=, s=, v=}
--              or as {h=, s=, l=}
--              or another Color
--
-- @return self
function Color:set(value)
  if value.__is_color then
    self.r = value.r
    self.g = value.g
    self.b = value.b
  elseif type(value) == "string" then
    local r, g, b = value:match "(%x%x)(%x%x)(%x%x)"
    assert(r ~= nil)
    self.r = tonumber(r, 16) / 255
    self.g = tonumber(g, 16) / 255
    self.b = tonumber(b, 16) / 255
  elseif value.r ~= nil then
    self.r = value.r
    self.g = value.g
    self.b = value.b
  else
    local hue, saturation = value.h, value.s
    assert(hue ~= nil, saturation ~= nil)

    local r, g, b = 0, 0, 0

    if value.v ~= nil then
      local v = value.v
      local chroma = saturation * v
      r, g, b = hcm_to_rgb(hue, chroma, v - chroma)

    elseif value.l ~= nil then
      local lightness = value.l
      local chroma = (1 - math.abs(2 * lightness - 1)) * saturation
      r, g, b = hcm_to_rgb(hue, chroma, lightness - chroma / 2)
    end

    self.r = r
    self.g = g
    self.b = b
  end

  return self
end



--- Get rgb values
--
-- @return red, green, blue
function Color:rgb()
  return self.r, self.g, self.b
end

--- Get hsv values
--
-- @return hue, saturation, value, min_value
function Color:hsv()
  local r, g, b = self.r, self.g, self.b

  local max, max_i = max_ind(r, g, b)
  local min = math.min(r, g, b)
  local chroma = max - min

  local hue
  if chroma == 0 then
    hue = 0
  elseif max_i == 1 then
    hue = (    (g - b) / chroma) / 6
  elseif max_i == 2 then
    hue = (2 + (b - r) / chroma) / 6
  elseif max_i == 3 then
    hue = (4 + (r - g) / chroma) / 6
  end

  local saturation = max == 0 and 0 or chroma / max

  return hue, saturation, max, min
end

--- Get hsl values
---
-- @return hue, saturation, lightness
function Color:hsl()
  local hue, _, max, min = self:hsv()
  local lightness = (max + min) / 2

  local saturation = lightness == 0 and 0
    or (max - lightness) / math.min(lightness, 1 - lightness)

  return hue, saturation, lightness
end



--- Rotate hue of color
--
-- @param value Angle as factor of a full turn [0,1]
--              or as {deg=} degree
--              or as {rad=} radians
--
-- @return self
function Color:rotate(value)
  local r
  if type(value) == "number" then
    r = value
  elseif value.rad ~= nil then
    r = value.rad / (math.pi * 2)
  elseif value.deg ~= nil then
    r = value.deg / 360
  else
    error("No valid argument")
  end

  local h, s, v = self:hsv()
  h = (h + r) % 1
  self:set {h = h, s = s, v = v}

  return self
end

--- Invert the color
--
-- @return self
function Color:invert()
  self.r = 1 - self.r
  self.g = 1 - self.g
  self.b = 1 - self.b
  return self
end



--- Get color in rgb hex notation
function Color:__tostring()
  return string.format(
    "#%02x%02x%02x",
    round(self.r * 255),
    round(self.g * 255),
    round(self.b * 255)
  )
end

--- Get inverted clone of color
function Color:__unm()
  return Color(self):invert()
end

--- Check if colors are equal
function Color:__eq(other)
  return self.r == other.r
    and self.g == other.g
    and self.b == other.b
end



--- Check whether `color` is a Color
--
-- @param color
--
-- @return boolean
function Color.isColor(color)
  return color ~= nil and color.__is_color == true
end



return Color
