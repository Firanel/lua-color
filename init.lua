--- Parse, convert and manipulate color values.
--
-- @classmod Color



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

local function tonumPercent(str)
  if str:sub(-1) == "%" then
    return tonumber(str:sub(1, #str - 1)) / 100
  end
  return tonumber(str)
end



-- Color


--- Color constructor.
--
-- @function Color:__call
--
-- @tparam ?string|table|Color value Color value (default: `nil`)
--
-- @see Color:set


--- Color class
--
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

--- Table of color names.
-- <br>
-- Can be set to a table containing named colors to be used by `Color:set`
-- <br>
-- Values must be compatible with `Color:set`
-- <br>
-- Default: `nil`
--
-- @usage  Color.colorNames = { red = "#ff0000", green = "#00ff00", blue = "#0000ff" }
--local color = Color "green"
Color.colorNames = nil

--- Clone color
--
-- @treturn Color copy
function Color:clone()
  return Color(self)
end

--- Set color to value.
-- <br>
-- Called by constructor
-- <br><br>
-- Possible value types:
-- <ul>
--  <li>`Color`</li>
--  <li>color name as specified in `Color.colorNames`</li>
--  <li>css style functions as string:<ul>
--   <li>`rgb(r, g, b)`</li>
--   <li>`rgba(r, g, b, a)`</li>
--   <li>`hsl(h, s, l)`</li>
--   <li>`hsla(h, s, l, a)`</li>
--   <li>`hsv(h, s, v)`</li>
--   <li>`hsva(h, s, v, a)`</li>
--   <li>`cmyk(c, m, y, k)`</li>
--   </ul>
--   Values are in the same ranges as in css ([0;255] for rgb, [0;1] for alpha, ...)<br>
--   functions can be specified in a simplified syntax: `rgb(r, g, b) == rgb r g b`
--  </li>
--  <li>hex string: `#rgb` | `#rgba` | `#rrggbb` | `#rrggbbaa` (`#` can be omitted)</li>
--  <li>rgb values in [0;1]: `{r, g, b[, a]}` | `{r=r, g=g, b=b[, a=a]}`</li>
--  <li>hsv values in [0;1]: `{h=h, s=s, v=v[, a=a]}`</li>
--  <li>hsl values in [0;1]: `{h=h, s=s, l=l[, a=a]}`</li>
-- </ul>
--
-- @see Color:__call
--
-- @tparam string|table|Color value Color
--
-- @treturn Color self
--
-- @usage color:set "#f1f1f1"
-- @usage color:set "rgba(241, 241, 241, 0.5)"
-- @usage color:set "hsl 180 100% 20%"
-- @usage color:set { r = 0.255, g = 0.729, b = 0.412 }
-- @usage color:set { 0.255, 0.729, 0.412 } -- same as above
-- @usage color:set { h = 0.389, s = 0.65, v = 0.73 }
function Color:set(value)
  assert(value)

  -- from Color
  if value.__is_color then
    self.r = value.r
    self.g = value.g
    self.b = value.b
    self.a = value.a


  elseif type(value) == "string" then
    self.a = 1

    if value:sub(1, 1) ~= "#" then
      if Color.colorNames then
        local c = Color.colorNames[value]
        if c then return self:set(c) end
      end

      local func, values = value:match "(%w+)[ %(]+([x ,.%x%%]+)"
      if func == "rgb" then
        local r, g, b = values:match "([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+)"
        assert(r and g and b)
        self.r = tonumber(r) / 0xff
        self.g = tonumber(g) / 0xff
        self.b = tonumber(b) / 0xff
        return self
      elseif func == "rgba" then
        local r, g, b, a = values:match "([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+%%?)"
        assert(r and g and b and a)
        self.r = tonumber(r) / 0xff
        self.g = tonumber(g) / 0xff
        self.b = tonumber(b) / 0xff
        self.a = tonumPercent(a)
        return self
      elseif func == "hsv" then
        local h, s, v = values:match "([x.%x]+)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
        assert(h and s and v)
        return self:set {
          h = tonumber(h) / 360,
          s = tonumPercent(s),
          v = tonumPercent(v),
        }
      elseif func == "hsva" then
        local h, s, v, a = values:match "([x.%x]+)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
        assert(h and s and v and a)
        return self:set {
          h = tonumber(h) / 360,
          s = tonumPercent(s),
          v = tonumPercent(v),
          a = tonumPercent(a)
        }
      elseif func == "hsl" then
        local h, s, l = values:match "([x.%x]+)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
        assert(h and s and l)
        return self:set {
          h = tonumber(h) / 360,
          s = tonumPercent(s),
          l = tonumPercent(l),
        }
      elseif func == "hsla" then
        local h, s, v, a = values:match "([x.%x]+)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
        assert(h and s and v and a)
        return self:set {
          h = tonumber(h) / 360,
          s = tonumPercent(s),
          l = tonumPercent(l),
          a = tonumPercent(a)
        }
      elseif func == "cmyk" then
        local c, m, y, k = values:match "([x.%x]+%%?)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
        assert(c and m and y and k)
        return self:set {
          c = tonumPercent(c),
          m = tonumPercent(m),
          y = tonumPercent(y),
          k = tonumPercent(k),
        }
      end
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

  -- table with rgb
  elseif value[1] ~= nil then
    self.r = value[1]
    self.g = value[2] or 0
    self.b = value[3] or 0
    self.a = value[4] or 1
  elseif value.r ~= nil then
    self.r = value.r
    self.g = value.g or 0
    self.b = value.b or 0
    self.a = value.a or 1

  elseif value.c ~= nil then
    local k = 1 - value.k
    self.r = (1 - value.c) * k
    self.g = (1 - value.m) * k
    self.b = (1 - value.y) * k

  -- table with hs?
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

  local r, g, b, a = self.r, self.g, self.b, self.a
  assert(r and g and b and a, "Color invalid")
  assert(r >= 0 and r <= 1, "red value out of bounds")
  assert(g >= 0 and g <= 1, "green value out of bounds")
  assert(b >= 0 and b <= 1, "blue value out of bounds")
  assert(a >= 0 and a <= 1, "alpha value out of bounds")
  return self
end



--- Get rgb values.
--
-- @treturn number[0;1] red
-- @treturn number[0;1] green
-- @treturn number[0;1] blue
function Color:rgb()
  return self.r, self.g, self.b
end

--- Get rgba values.
--
-- @treturn number[0;1] red
-- @treturn number[0;1] green
-- @treturn number[0;1] blue
-- @treturn number[0;1] alpha
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

--- Get hsv values.
--
-- @treturn number[0;1] hue
-- @treturn number[0;1] saturation
-- @treturn number[0;1] value
function Color:hsv()
  local h, s, v = self:_hsvm()
  return h, s, v
end

--- Get hsv values.
--
-- @treturn number[0;1] hue
-- @treturn number[0;1] saturation
-- @treturn number[0;1] value
-- @treturn number[0;1] alpha
function Color:hsva()
  local h, s, v = self:_hsvm()
  return h, s, v, self.a
end


--- Get hsl values.
--
-- @treturn number[0;1] hue
-- @treturn number[0;1] saturation
-- @treturn number[0;1] lightness
function Color:hsl()
  local hue, _, max, min = self:hsv()
  local lightness = (max + min) / 2

  local saturation = lightness == 0 and 0
    or (max - lightness) / math.min(lightness, 1 - lightness)

  return hue, saturation, lightness
end

--- Get hsl values.
--
-- @treturn number[0;1] hue
-- @treturn number[0;1] saturation
-- @treturn number[0;1] lightness
-- @treturn number[0;1] alpha
function Color:hsla()
  local h, s, l = self:hsl()
  return h, s, l, self.a
end

--- Get cmyk values.
--
-- @treturn number[0;1] cyan
-- @treturn number[0;1] magenta
-- @treturn number[0;1] yellow
-- @treturn number[0;1] key
function Color:cmyk()
  local r, g, b = self.r, self.g, self.b
  local K = math.max(r, g, b)
  local k = 1 - K
  local c = (K - r) / K
  local m = (K - g) / K
  local y = (K - b) / K
  return c, m, y, k
end



--- Rotate hue of color.
--
-- @tparam number[0;1]|table value Part of full turn or table containing degree or radians
--
-- @treturn Color self
--
-- @usage color:rotate(0.5)
-- @usage color:rotate {deg=180}
-- @usage color:rotate {rad=math.pi}
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

--- Invert the color.
--
-- @treturn Color self
function Color:invert()
  self.r = 1 - self.r
  self.g = 1 - self.g
  self.b = 1 - self.b
  return self
end



--- Generate complementary color.
--
-- @treturn Color
function Color:complement()
  return Color(self):rotate(0.5)
end

--- Generate analogous color scheme.
--
-- @treturn Color
-- @treturn Color self
-- @treturn Color
function Color:analogous()
  local h, s, v = self:hsv()
  return Color {h = (h - 1/12) % 1, s = s, v = v, a = self.a},
    self,
    Color {h = (h + 1/12) % 1, s = s, v = v, a = self.a}
end

--- Generate triadic color scheme.
--
-- @treturn Color self
-- @treturn Color
-- @treturn Color
function Color:triad()
  local h, s, v = self:hsv()
  return self,
    Color {h = (h + 1/3) % 1, s = s, v = v, a = self.a},
    Color {h = (h + 2/3) % 1, s = s, v = v, a = self.a}
end

--- Generate tetradic color scheme.
--
-- @treturn Color self
-- @treturn Color
-- @treturn Color
-- @treturn Color
function Color:tetrad()
  local h, s, v = self:hsv()
  return self,
    Color {h = (h + 1/4) % 1, s = s, v = v, a = self.a},
    Color {h = (h + 2/4) % 1, s = s, v = v, a = self.a},
    Color {h = (h + 3/4) % 1, s = s, v = v, a = self.a}
end



--- Get color in rgb hex notation.
-- <br>
-- only adds alpha value if `color.a < 1`
--
-- @treturn string `#rrggbb` | `#rrggbbaa`
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

--- Get inverted clone of color.
--
-- @treturn Color
function Color:__unm()
  return Color(self):invert()
end

--- Check if colors are equal.
--
-- @tparam Color other
--
-- @treturn boolean all values are equal
function Color:__eq(other)
  return self.r == other.r
    and self.g == other.g
    and self.b == other.b
    and self.a == other.a
end



--- Check whether `color` is a Color.
--
-- @param color
--
-- @treturn boolean is a color
--
-- @usage if Color.isColor(color) then print "It's a color!" end
function Color.isColor(color)
  return color ~= nil and color.__is_color == true
end



return Color
