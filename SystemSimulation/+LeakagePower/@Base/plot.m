function plot(this)
  [ V, T ] = meshgrid( ...
    linspace(this.VRange(1), this.VRange(2), 50), ...
    linspace(this.TRange(1), this.TRange(2), 50));

  I = this.evaluate(this.output, V, T);

  figure;
  line(V, Utils.toCelsius(T), I, ...
    'LineStyle', 'None', ...
    'Marker', 'o', ...
    'MarkerEdgeColor', 'w', ...
    'MarkerFaceColor', 'b');

  Plot.title('Leakage current');
  Plot.label('Variable', 'Temperature, C', 'Leakage current, A');

  grid on;
  view(10, 10);
end
