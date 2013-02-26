function construct(this, options)
  dieFloorplan = dlmread(options.floorplan, '', 0, 1);

  columnCount = options.columnCount;
  rowCount = options.rowCount;

  W = dieFloorplan(:, 1);
  H = dieFloorplan(:, 2);
  X = dieFloorplan(:, 3);
  Y = dieFloorplan(:, 4);

  DW = max(X + W);
  DH = max(Y + H);
  DS = max(DW, DH);

  waferCenterX = DS * columnCount / 2;
  waferCenterY = DS * rowCount / 2;

  floorplan = zeros(0, 6);

  for i = 1:rowCount
    for j = 1:columnCount
      x = (j - 0.5) * DS;
      y = (i - 0.5) * DS;
      e = ((x - waferCenterX) / waferCenterX)^2 + ...
          ((y - waferCenterY) / waferCenterY)^2;

      if e > 1, continue; end

      floorplan(end + 1, :) = [ ...
        ... The center of the die along the X axis.
        (j - 1) * DS + (DS - DW) / 2 - waferCenterX, ...
        ... The center of the die along the Y axis.
        (i - 1) * DS + (DS - DH) / 2 - waferCenterY, ...
        ... The bottom left corner of the die along the X axis.
        (j - 1) * DS                 - waferCenterX, ...
        ... The bottom left corner of the die along the Y axis.
        (i - 1) * DS                 - waferCenterY, ...
        ... The row number of the die.
        i, ...
        ... The column number of the die.
        j ];
    end
  end

  this.rowCount = rowCount;
  this.columnCount = columnCount;

  this.floorplan = floorplan;
  this.width  = DS * columnCount;
  this.height = DS * rowCount;
  this.radius = sqrt((this.width / 2)^2 + (this.height / 2)^2);

  this.dieFloorplan = dieFloorplan;
  this.dieWidth = DW;
  this.dieHeight = DH;

  this.dieCount = size(floorplan, 1);
  this.processorCount = size(dieFloorplan, 1);
end
