function construct(this, options)
  this.filename = options.floorplan;

  this.floorplan = dlmread(this.filename, '', 0, 1);

  DX = this.floorplan(:, 1);
  DY = this.floorplan(:, 2);
  DW = this.floorplan(:, 3);
  DH = this.floorplan(:, 4);

  this.width  = max(DX + DW);
  this.height = max(DY + DH);
  this.radius = sqrt((this.width / 2)^2 + (this.height / 2)^2);

  this.processorCount = size(this.floorplan, 1);
end
