function plot(this)
  Inom = this.predict(this.Lnom, Utils.toKelvin(27));

  Ldata = this.Ldata;
  Tdata = this.Tdata;
  Idata = this.Idata / Inom;

  figure;
  h = subplot(1, 1, 1);

  Luni = sort(unique(Ldata));
  Tuni = sort(unique(Tdata));

  [ L, T ] = meshgrid(Luni, Tuni);

  I = griddata(Ldata, Tdata, Idata, L, T);

  mesh(L, T, I);

  line(Ldata, Tdata, this.predict(Ldata, Tdata) / Inom, ...
    'LineStyle', 'None', ...
    'Marker', 'o', ...
    'MarkerEdgeColor', 'w', ...
    'MarkerFaceColor', 'b', ...
    'Parent', h);

  Plot.title('Normalized leakage current');
  Plot.label('Channel length, mm', 'Temperature, K', ...
    'Normalized leakage current');

  grid on;
  view(10, 10);
end
