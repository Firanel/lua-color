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

function round(x)
  return x + 0.5 - (x + 0.5) % 1
end
