function cycles(data, partitions, weights, varargin)
  options = Options(varargin{:});

  assert(isvector(data));
  stepCount = numel(data);
  cycleCount = length(weights);

  timeLine = options.get('timeLine', 0:(stepCount - 1));
  labels = options.get('labels', { 'Time, #', '' });

  if options.get('figure', true), Plot.figure(800, 400); end

  I = unique(partitions(:), 'sorted');
  Plot.line(timeLine, data, 'style', { 'Color', 'k', ...
    'LineStyle', ':' }, 'labels', labels);
  Plot.line(timeLine(I), data(I), 'style', { 'Color', 'r', ...
    'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 8 });

  Plot.limit(timeLine);
  Plot.label(labels);

  x = linspace(0, 1, 50);

  for c = 1:cycleCount
    color = Color.pick(c);

    i = partitions(1, c);
    j = partitions(2, c);

    period = 2 * (timeLine(j) - timeLine(i));
    amplitude = abs(data(i) - data(j)) / 2;
    mean = (data(i) + data(j)) / 2;

    if weights(c) == 1
      if data(i) < data(i + 1),
        Plot.line(period * x + timeLine(i), ...
          cos(pi + x .* 2 * pi) * amplitude + mean, 'number', c);
        text(timeLine(i), mean - amplitude, [ int2str(c) '. Cycle up' ], ...
          'Color', color, 'VerticalAlignment', 'top');
      else
        Plot.line(period * x + timeLine(i), ...
          cos(x .* 2 * pi) * amplitude + mean, 'number', c);
        text(timeLine(i), mean + amplitude, [ int2str(c) '. Cycle down' ], ...
          'Color', color, 'VerticalAlignment', 'bottom');
      end
    else
      if data(i) > data(j)
        Plot.line(0.5 * period * x + timeLine(i), ...
          cos(x .* pi) * amplitude + mean, 'number', c);
        text(timeLine(i), mean + amplitude, [ int2str(c) '. Half-cycle down' ], ...
          'Color', color, 'VerticalAlignment', 'bottom');
      else
        Plot.line(0.5 * period * x + timeLine(i), ...
          cos(pi + x .* pi) * amplitude + mean, 'number', c);
        text(timeLine(i), mean - amplitude, [ int2str(c) '. Half-cycle up' ],...
          'Color', color, 'VerticalAlignment', 'top');
      end
    end
  end
end
