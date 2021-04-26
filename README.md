# Lua Color

Convert and manipulate color values.


## Install

Use `luarocks install lua-color` or add folder to your project root.


## Examples

```lua
local Color = require "lua-color"

local color = Color "#41ba69"

-- Get color as hsv
local h, s, v = color:hsv()
print(h * 360, s * 100, v * 100)

-- Get complementary color
print(color:rotate {deg = 180})
```
