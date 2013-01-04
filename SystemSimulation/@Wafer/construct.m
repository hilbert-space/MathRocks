function construct(this, options)
  D = dlmread(options.floorplan, '', 0, 1);

  columns = options.columns;
  rows = options.rows;

  W = D(:, 1);
  H = D(:, 2);
  X = D(:, 3);
  Y = D(:, 4);

  dieW = max(X + W);
  dieH = max(Y + H);

  waferCenterX = dieW * columns / 2;
  waferCenterY = dieH * rows / 2;

  layout = zeros(0, 2);

  for i = 1:rows
    for j = 1:columns
      x = (j - 0.5) * dieW;
      y = (i - 0.5) * dieH;
      e = ((x - waferCenterX) / waferCenterX)^2 + ...
        ((y - waferCenterY) / waferCenterY)^2;
      if e > 1, continue; end
      layout(end + 1, :) = [ (j - 1) * dieW, (i - 1) * dieH ];
    end
  end

  this.layout = layout;
  this.floorplan = D;
  this.dieWidth = dieW;
  this.dieHeight = dieH;
end
