# Lua Color

Convert and manipulate color values.


## Install

Use `luarocks install lua-color` or add folder to your project root.

## Documentation

The documentation is availabale [here](https://firanel.github.io/lua-color/index.html)
or from the *docs* folder.

## Usage

### Import
```lua
local Color = require "lua-color"

-- Use x11 color names
Color.colorNames = require "lua-color.colors.X11"

-- Use color names from file
local colors = require "lua-color.colors"
Color.colorNames = colors.load "my-colors.conf"
```

### Create new color
```lua
-- With X11 colors enabled
local color = Color "crimson"

-- These create (roughly) the same color
-- (full list of options in the docs @see Color:set)
local color = Color "#41ba69"
local color = Color "hsva 140 65% 73% 1"
local color = Color "cmyk 65% 0% 44% 27%"
local color = Color { r = 0.255, g = 0.729, b = 0.412 }
local color = Color { 0.255, 0.729, 0.412 }
local color = Color { h = 0.389, s = 0.65, v = 0.73 }

local new_color = Color(color)
```

### Retrieve the color
```lua
-- Print color as hex string
print(color)

-- Print color as hsv
local h, s, v = color:hsv()
print(h * 360, s * 100, v * 100)

-- Print color as hsla
local h, s, l, a = color:hsla()
print(h * 360, s * 100, l * 100, a)

-- Print color as rgba
local r, g, b, a = color:rgba()
print(r * 255, g * 255, b * 255, a)

-- Print color as cmyk
print(color:cmyk())
```

### Manipulate the color
```lua
-- Get complementary color
color:rotate(0.5)
color:rotate {deg = 180}
color:rotate {rad = math.pi}

-- Get inverse
color:invert()
local new_color = -color

-- to greyscale
color:grey()

-- to black or white depending on lightness
color:blackOrWhite()

-- Mix two colors
color:mix(other_color, 0.3) -- mix colors with 70:30 ratio
local new_color = color + other_color -- mix colors 50:50 and return new
local new_color = color - other_color -- complement of +

-- Apply mask
local new_color = color & 0xff00ff -- Get color without green component
```

### Generate color scheme
``` lua
-- Complementary
local complementary_color = color:complement()

-- Analogous
local new_a, orig, new_b = color:analogous()

-- Triadic
local orig, new_a, new_b = color:triad()

-- Tetradic
local orig, new_a, new_b, new_c = color:tetrad()

-- Compound
local new_a, orig, new_b = color:compound()

-- Pentadic (and so forth)
local cols = color:evenlySpaced(5)

-- Combine
-- Example: Analogous color scheme around complement
local new_a, new_b, new_c = color:complement():analogous()
```

### Other
```lua
-- Check if variable is color
if Color.isColor(color) then print "It's a color!" end

-- Equate colors
assert(color == color:clone())
```

