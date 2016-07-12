function color = brighten(color, change)
  color = color + change;
  color = min([color; 1, 1, 1], [], 1);
  color = max([color; 0, 0, 0], [], 1);
end
