function construct(this, options)
  dieFloorplan = dlmread(options.floorplan, '', 0, 1);

  columns = options.columns;
  rows = options.rows;

  W = dieFloorplan(:, 1);
  H = dieFloorplan(:, 2);
  X = dieFloorplan(:, 3);
  Y = dieFloorplan(:, 4);

  dieW = max(X + W);
  dieH = max(Y + H);

  waferCenterX = dieW * columns / 2;
  waferCenterY = dieH * rows / 2;

  floorplan = zeros(0, 2);

  for i = 1:rows
    for j = 1:columns
      x = (j - 0.5) * dieW;
      y = (i - 0.5) * dieH;
      e = ((x - waferCenterX) / waferCenterX)^2 + ...
        ((y - waferCenterY) / waferCenterY)^2;
      if e > 1, continue; end
      floorplan(end + 1, :) = [ ...
        (j - 1) * dieW - waferCenterX, ...
        (i - 1) * dieH - waferCenterY ];
    end
  end

  this.floorplan = floorplan;
  this.width = max(floorplan(:, 1)) + dieW;
  this.height = max(floorplan(:, 2)) + dieH;

  this.dieFloorplan = dieFloorplan;
  this.dieWidth = dieW;
  this.dieHeight = dieH;

  this.dieCount = size(floorplan, 1);
  this.processorCount = size(dieFloorplan, 1);
end
