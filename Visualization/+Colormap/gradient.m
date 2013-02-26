function values = gradient(color1, color2, colorCount)
  if nargin < 3, colorCount = 20; end

  color1 = repmat(color1(:)', colorCount, 1);
  color2 = repmat(color2(:)', colorCount, 1);

  values = color1 + (color2 - color1) .* ...
    repmat(linspace(0, 1, colorCount)', 1, 3);

  colormap(values);
end
