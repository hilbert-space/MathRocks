function construct(this, options)
  dieFloorplan = dlmread(options.floorplan, '', 0, 1);

  columns = options.columns;
  rows = options.rows;

  W = dieFloorplan(:, 1);
  H = dieFloorplan(:, 2);
  X = dieFloorplan(:, 3);
  Y = dieFloorplan(:, 4);

  DW = max(X + W);
  DH = max(Y + H);
  DS = max(DW, DH);

  waferCenterX = DS * columns / 2;
  waferCenterY = DS * rows / 2;

  floorplan = zeros(0, 6);

  for i = 1:rows
    for j = 1:columns
      x = (j - 0.5) * DS;
      y = (i - 0.5) * DS;
      e = ((x - waferCenterX) / waferCenterX)^2 + ...
          ((y - waferCenterY) / waferCenterY)^2;
      if e > 1, continue; end
      floorplan(end + 1, :) = [ ...
        (j - 1) * DS + (DS - DW) / 2 - waferCenterX, ...
        (i - 1) * DS + (DS - DH) / 2 - waferCenterY, ...
        (j - 1) * DS                 - waferCenterX, ...
        (i - 1) * DS                 - waferCenterY, i, j ];
    end
  end

  this.floorplan = floorplan;
  this.width  = DS * columns;
  this.height = DS * rows;
  this.radius = sqrt((this.width / 2)^2 + (this.height / 2)^2);

  this.dieFloorplan = dieFloorplan;
  this.dieWidth = DW;
  this.dieHeight = DH;

  this.dieCount = size(floorplan, 1);
  this.processorCount = size(dieFloorplan, 1);
end
