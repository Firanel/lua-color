---
-- Table of X11 color names.
--
-- Data pulled from `https://gitlab.freedesktop.org/xorg/xserver/-/raw/master/os/oscolor.c`
--
-- @usage Color.colorNames = require "lua-color.colors.X11"
--
-- @see Color:colorNames

local __DIR__ = debug.getinfo(1, 'S').source:match "^@(.*)/[^/]+$"

local filename = __DIR__.."/X11.csv"

local colors = {}

local f = io.open(filename)
if f == nil then
  assert(os.execute(string.format('bash "%s/loadX11colors.sh" &>/dev/null', __DIR__)))
  f = io.open(filename)
end
assert(f)

while true do
  local line = f:read()
  if line == nil then break end

  local name, r, g, b = line:match "^([^,]+),(%d+) (%d+) (%d+)$"
  colors[name] = {
    tonumber(r) / 0xff,
    tonumber(g) / 0xff,
    tonumber(b) / 0xff,
  }
end


return colors
