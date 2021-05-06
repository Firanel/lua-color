function min_ind(first, ...)
  local min, ind = first, 1
  for i, v in ipairs {...} do
    if v < min then
      min, ind = v, i + 1
    end
  end
  return min, ind
end

function max_ind(first, ...)
  local max, ind = first, 1
  for i, v in ipairs {...} do
    if v > max then
      max, ind = v, i + 1
    end
  end
  return max, ind
end

if math.round == nil then
  function math.round(x)
    return x + 0.5 - (x + 0.5) % 1
  end
end

if math.clamp == nil then
  function math.clamp(x, min, max)
    return x < min and min or x > max and max or x
  end
end
