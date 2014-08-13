function extrema(data, index, varargin)
  options = Options(varargin{:});

  [componentCount, stepCount] = size(data);

  timeLine = options.get('timeLine', 0:(stepCount - 1));
  labels = options.get('labels', { 'Time, #', '' });

  legend = cell(1, componentCount);
  for i = 1:componentCount
    legend{i} = sprintf('Component %d', i);
  end

  Plot.figure(800, 600);

  %
  % Draw the full curves
  %
  subplot(2, 1, 1);
  Plot.lines(timeLine, data, 'labels', labels);

  set(gca, 'XLim', [0 timeLine(end)]);
  YLim = get(gca, 'YLim');

  %
  % Mark the extrema
  %
  Plot.lines(timeLine, data, 'index', index, ...
    'style', { 'LineStyle', 'none', 'Marker', 'x' });

  %
  % Draw curves only by the extrema
  %
  subplot(2, 1, 2);
  Plot.lines(timeLine, data, 'index', index, 'labels', labels);

  upperBound = max(data(:));
  lowerBound = min(data(:));

  %
  % Draw the minimal value
  %
  line([timeLine(1), timeLine(end)], [lowerBound, lowerBound], ...
    'Line', '--', 'Color', 'k');
  legend{end + 1} = 'Minimum';

  %
  % Draw the maximal value
  %
  line([timeLine(1), timeLine(end)], [upperBound, upperBound], ...
    'Line', '-.', 'Color', 'k');
  legend{end + 1} = 'Maximum';

  set(gca, 'XLim', [0 timeLine(end)]);
  set(gca, 'YLim', YLim);

  Plot.legend(legend{:});
end
