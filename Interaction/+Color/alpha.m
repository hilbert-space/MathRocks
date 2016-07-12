function color = brighten(color1, color2, change)
  color = change * color1 + (1 - change) * color2;
end
