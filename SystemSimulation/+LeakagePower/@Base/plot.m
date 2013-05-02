function plot(this)
  Ldata = this.Ldata;
  Tdata = this.Tdata;
  Idata = this.Idata;
  Ipred = this.evaluate(Ldata, Tdata);

  error = Error.computeNRMSE(Idata, Ipred);

  figure;
  h = subplot(1, 1, 1);

  Luni = sort(unique(Ldata));
  Tuni = sort(unique(Tdata));

  [ L, T ] = meshgrid(Luni, Tuni);

  I = griddata(Ldata, Tdata, Idata, L, T);

  mesh(L, Utils.toCelsius(T), I);

  line(Ldata, Utils.toCelsius(Tdata), Ipred, ...
    'LineStyle', 'None', ...
    'Marker', 'o', ...
    'MarkerEdgeColor', 'w', ...
    'MarkerFaceColor', 'b', ...
    'Parent', h);

  Plot.title('Leakage current (NRMSE %.2f%%)', error * 100);
  Plot.label('Channel length, m', 'Temperature, C', ...
    'Leakage current, A');

  grid on;
  view(10, 10);
end
