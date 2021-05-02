# Lua Color

Convert and manipulate color values.


## Install

Use `luarocks install lua-color` or add folder to your project root.


## Usage

### Import
```lua
local Color = require "lua-color"
```

### Create new color
```lua
-- These create (roughly) the same color
local color = Color "#41ba69"
local color = Color { r = 0.255, g = 0.729, b = 0.412 }
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

-- Print color as rgb
local r, g, b = color:rgb()
print(r * 255, g * 255, b * 255)
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

