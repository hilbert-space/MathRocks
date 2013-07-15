function plot(this)
  [ Lgrid, Tgrid, Igrid ] = Utils.loadLeakageData(this.options);
  Ipred = this.evaluate(Lgrid, Tgrid);

  error = Error.computeNRMSE(Igrid, Ipred);

  figure;
  h = subplot(1, 1, 1);

  mesh(Lgrid, Utils.toCelsius(Tgrid), Igrid);

  line(Lgrid, Utils.toCelsius(Tgrid), Ipred, ...
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
