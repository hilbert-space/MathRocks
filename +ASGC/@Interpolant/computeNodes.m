function values = computeNodes(this, level, count)
  if count == 1
    values = [ 0.5 ];
  else
    values = ((1:count)' - 1) / (count - 1);
  end
end
