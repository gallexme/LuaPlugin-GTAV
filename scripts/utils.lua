table.filter = function(t, filterIter)
  local out = {}
 
  for k, v in pairs(t) do
    if filterIter(v, k, t) then out[k] = v end
  end
 
  return out
end