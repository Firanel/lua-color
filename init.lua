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
    this.a = 1
  end
end)

--- Clone color
function Color:clone()
  return Color(self)
end

--- Set color to value
--
-- @param value Color in hex notation
--              or as {r=, g=, b=[, a=]}
--              or as {h=, s=, v=[, a=]}
--              or as {h=, s=, l=[, a=]}
--              or another Color object
--
-- @return self
function Color:set(value)
  if value.__is_color then
    self.r = value.r
    self.g = value.g
    self.b = value.b
    self.a = value.a

  elseif type(value) == "string" then
    self.a = 1

    if value:sub(1, 1) ~= "#" then
      -- TODO: parse color by name or function
    else
      value = value:sub(2)
    end

    local pattern
    local div = 0xff
    if #value == 3 then
      pattern = "(%x)(%x)(%x)"
      div = 0xf
    elseif #value == 4 then
      pattern = "(%x)(%x)(%x)(%x)"
      div = 0xf
    elseif #value == 6 then
      pattern = "(%x%x)(%x%x)(%x%x)"
    elseif #value == 8 then
      pattern = "(%x%x)(%x%x)(%x%x)(%x%x)"
    else
      error "Not a valid color"
    end
    local r, g, b, a = value:match(pattern)
    assert(r ~= nil, "Not a valid color")
    self.r = tonumber(r, 16) / div
    self.g = tonumber(g, 16) / div
    self.b = tonumber(b, 16) / div
    self.a = a ~= nil and tonumber(a, 16) / div or 1

  elseif value.r ~= nil then
    self.r = value.r
    self.g = value.g
    self.b = value.b
    self.a = value.a or 1

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
    self.a = value.a or 1
  end

  return self
end



--- Get rgb values
--
-- @return red, green, blue
function Color:rgb()
  return self.r, self.g, self.b
end

--- Get rgba values
--
-- @return red, green, blue, alpha
function Color:rgba()
  return self.r, self.g, self.b, self.a
end


function Color:_hsvm()
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

--- Get hsv values
--
-- @return hue, saturation, value
function Color:hsv()
  local h, s, v = self:_hsvm()
  return h, s, v
end

--- Get hsv values
--
-- @return hue, saturation, value, alpha
function Color:hsva()
  local h, s, v = self:_hsvm()
  return h, s, v, self.a
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

--- Get hsl values
---
-- @return hue, saturation, lightness, alpha
function Color:hsla()
  local h, s, l = self:hsl()
  return h, s, l, self.a
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
  self:set {h = h, s = s, v = v, a = self.a}

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



--- Generate analogous color scheme
--
-- @return Color, self, Color
function Color:analogous()
  local h, s, v = self:hsv()
  return Color {h = (h - 1/12) % 1, s = s, v = v, a = self.a},
    self,
    Color {h = (h + 1/12) % 1, s = s, v = v, a = self.a}
end

--- Generate triadic color scheme
--
-- @return self, Color, Color
function Color:triad()
  local h, s, v = self:hsv()
  return self,
    Color {h = (h + 1/3) % 1, s = s, v = v, a = self.a},
    Color {h = (h + 2/3) % 1, s = s, v = v, a = self.a}
end

--- Generate tetradic color scheme
--
-- @return self, Color, Color, Color
function Color:tetrad()
  local h, s, v = self:hsv()
  return self,
    Color {h = (h + 1/4) % 1, s = s, v = v, a = self.a},
    Color {h = (h + 2/4) % 1, s = s, v = v, a = self.a},
    Color {h = (h + 3/4) % 1, s = s, v = v, a = self.a}
end



--- Get color in rgb hex notation
function Color:__tostring()
  if self.a < 1 then
    return string.format(
      "#%02x%02x%02x%02x",
      round(self.r * 0xff),
      round(self.g * 0xff),
      round(self.b * 0xff),
      round(self.a * 0xff)
    )
  else
    return string.format(
      "#%02x%02x%02x",
      round(self.r * 0xff),
      round(self.g * 0xff),
      round(self.b * 0xff)
    )
  end
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
    and self.a == other.a
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
