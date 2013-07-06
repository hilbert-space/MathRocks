function thermalCycles(lifetime, T, output)
  [ processorCount, stepCount ] = size(T);
  time = (0:(stepCount - 1)) * lifetime.samplingInterval;

  I = zeros(processorCount, stepCount);
  P = zeros(processorCount, stepCount);

  cycleLegend = {};

  for i = 1:processorCount
    MTTF = output.MTTF(i);
    peaks = output.peaks{i};
    cycles = output.cycles{i};

    cycleLegend{end + 1} = ...
      sprintf('Cycles %.1f (MTTF %.2e)', sum(cycles), MTTF);

    if size(peaks, 1) == 0
      j = [ 1; stepCount ];
      p = T(i, j);
    else
      j = peaks(:, 1);
      p = peaks(:, 2);
    end

    I(i, 1:length(j)) = j;
    P(i, 1:length(j)) = p;
  end

  T = Utils.toCelsius(T);
  P = Utils.toCelsius(P);

  figure;

  % Draw full curves
  subplot(2, 1, 1);
  Plot.lines(time, T, ...
    'labels', { 'Time, s', 'Temperature, C' });

  set(gca, 'XLim', [ 0 time(end) ]);
  YLim = get(gca, 'YLim');

  % Outline minima and maxima
  Plot.lines(time, P, 'index', I, ...
    'style', { 'LineStyle', 'none', 'Marker', 'x' });

  % Draw curves only by minima and maxima
  subplot(2, 1, 2);
  Plot.lines(time, P, 'index', I, ...
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
