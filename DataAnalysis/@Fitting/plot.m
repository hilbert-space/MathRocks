function plot(this)
  assert(this.parameterCount == 2);

  [ parameter1, parameter2 ] = meshgrid(this.parameterSweeps{:});
  target = this.evaluate(this.output, parameter1, parameter2);

  Plot.figure(800, 600);
  surfc(parameter1, parameter2, target);
  line(parameter1(:), parameter2(:), target(:), ...
    'LineStyle', 'None', ...
    'Marker', 'o', ...
    'MarkerEdgeColor', 'w', ...
    'MarkerFaceColor', 'b');
  Plot.title('Curve fitting');
  Plot.label('Parameter 1', 'Parameter 2', 'Target');

  grid on;
  view(-130, 45);
end
