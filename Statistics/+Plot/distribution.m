function distribution(Y, varargin)
  options = Options(varargin{:});

  dimensionCount = size(Y, 2);

  switch options.get('layout', 'tiles')
  case 'one'
    if options.get('figure', true), Plot.figure; end
    for i = 1:dimensionCount
      [y, x] = Utils.computeDistribution(Y(:, i), [], options);
      Plot.statistic(x, y, options, 'color', Color.pick(i));
    end
  case 'separate'
    for i = 1:dimensionCount
      Plot.figure;
      [y, x] = Utils.computeDistribution(Y(:, i), [], options);
      Plot.statistic(x, y, options);
    end
  case 'tiles'
    if options.get('figure', true), Plot.figure; end
    for i = 1:dimensionCount
      subplot(1, dimensionCount, i);
      [y, x] = Utils.computeDistribution(Y(:, i), [], options);
      Plot.statistic(x, y, options);
    end
  end
end
