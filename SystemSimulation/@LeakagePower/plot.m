function plot(this)
  Ldata = this.Ldata;
  Tdata = this.Tdata;
  Idata = this.Idata;

  figure;
  h = subplot(1, 1, 1);

  Luni = sort(unique(Ldata));
  Tuni = sort(unique(Tdata));

  [ L, T ] = meshgrid(Luni, Tuni);

  I = griddata(Ldata, Tdata, Idata, L, T);

  mesh(L, Utils.toCelsius(T), I);

  line(Ldata, Utils.toCelsius(Tdata), ...
    this.evaluate(Ldata, Tdata), ...
    'LineStyle', 'None', ...
    'Marker', 'o', ...
    'MarkerEdgeColor', 'w', ...
    'MarkerFaceColor', 'b', ...
    'Parent', h);

  Plot.title('Leakage current');
  Plot.label('Channel length, mm', 'Temperature, C', ...
    'Leakage current, A');

  grid on;
  view(10, 10);
end
