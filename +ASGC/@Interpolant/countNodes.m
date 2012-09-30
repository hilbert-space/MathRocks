function count = countNodes(this, level)
  if level == 1
    count = 1;
  else
    count = 2^(level - 1) + 1;
  end
end

