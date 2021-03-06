local function min_ind(first, ...)
  local min, ind = first, 1
  for i, v in ipairs {...} do
    if v < min then
      min, ind = v, i + 1
    end
  end
  return min, ind
end

local function max_ind(first, ...)
  local max, ind = first, 1
  for i, v in ipairs {...} do
    if v > max then
      max, ind = v, i + 1
    end
  end
  return max, ind
end

local function round(x)
  return x + 0.5 - (x + 0.5) % 1
end

local function clamp(x, min, max)
  return x < min and min or x > max and max or x
end

local function map(t, cb)
  local n = {}
  for i, v in ipairs(t) do
    n[i] = cb(v)
  end
  return n
end

return {
  min = min_ind,
  max = max_ind,
  round = round,
  clamp = clamp,
  map = map,
}
