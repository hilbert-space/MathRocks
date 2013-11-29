function distribution(data, varargin)
  options = Options(varargin{:});

  [ dataCount, dimensionCount ] = size(data);

  if dimensionCount > dataCount
    warning('Suspicious data: %d dimensions > %d data points.', ...
      dimensionCount, dataCount);
  end

  switch options.get('layout', 'tiles')
  case 'one'
    if options.get('figure', true), Plot.figure; end

    for i = 1:dimensionCount
      one = data(:, i);

      x = Utils.constructLinearSpace(one, options);
      one = Utils.computeDistribution(x, one, options);

      Plot.statistic(x, one, options, 'color', Color.pick(i));
    end
  case 'separate'
    for i = 1:dimensionCount
      Plot.figure;

      one = data(:, i);

      x = Utils.constructLinearSpace(one, options);
      one = Utils.computeDistribution(x, one, options);

      Plot.statistic(x, one, options);
    end
  case 'tiles'
    if options.get('figure', true), Plot.figure; end

    for i = 1:dimensionCount
      subplot(1, dimensionCount, i);

      one = data(:, i);

      x = Utils.constructLinearSpace(one, options);
      one = Utils.computeDistribution(x, one, options);

      Plot.statistic(x, one, options);
    end
  end
end
