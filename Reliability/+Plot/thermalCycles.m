function thermalCycles(T, output)
  [ processorCount, stepCount ] = size(T);

  T = Utils.toCelsius(T);
  time = (0:(stepCount - 1)) * output.samplingInterval;

  cycleLegend = {};
  for i = 1:processorCount
    cycleLegend{end + 1} = sprintf('Cycles %.1f (MTTF %.2e)', ...
      sum(output.cycles{i}), output.MTTF(i));
  end

  Plot.figure;

  % Draw full curves
  subplot(2, 1, 1);
  Plot.lines(time, T, ...
    'labels', { 'Time, s', 'Temperature, C' });

  set(gca, 'XLim', [ 0 time(end) ]);
  YLim = get(gca, 'YLim');

  % Outline minima and maxima
  Plot.lines(time, T, 'index', output.peakIndex, ...
    'style', { 'LineStyle', 'none', 'Marker', 'x' });

  % Draw curves only by minima and maxima
  subplot(2, 1, 2);
  Plot.lines(time, T, 'index', output.peakIndex, ...
    'labels', { 'Time, s', 'Temperature, C' });

  maxT = max(T(:));
  minT = min(T(:));

  % Draw the minimal temperature
  line([ time(1), time(end) ], [ minT, minT ], 'Line', '--', 'Color', 'k');
  cycleLegend{end + 1} = sprintf('Tmin (%.2f C)', minT);

  % Draw the maximal temperature
  line([ time(1), time(end) ], [ maxT, maxT ], 'Line', '-.', 'Color', 'k');
  cycleLegend{end + 1} = sprintf('Tmax (%.2f C)', maxT);

  set(gca, 'XLim', [ 0 time(end) ]);
  set(gca, 'YLim', YLim);

  legend(cycleLegend{:});
end
