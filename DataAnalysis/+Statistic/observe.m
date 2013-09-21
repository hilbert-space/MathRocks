function observe(varargin)
  [ data, options ] = Options.extract(varargin{:});
  assert(length(data) == 1, ...
    'The observation is supported only for one set of data.');
  observe2D(data{1}, options);
end

function observe2D(data, options)
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
      one = Statistic.compute(x, one, options);

      Statistic.draw(x, one, options, 'color', Color.pick(i));
    end
  case 'separate'
    for i = 1:dimensionCount
      Plot.figure;

      one = data(:, i);

      x = Utils.constructLinearSpace(one, options);
      one = Statistic.compute(x, one, options);

      Statistic.draw(x, one, options);
    end
  case 'tiles'
    if options.get('figure', true), Plot.figure; end

    for i = 1:dimensionCount
      subplot(1, dimensionCount, i);

      one = data(:, i);

      x = Utils.constructLinearSpace(one, options);
      one = Statistic.compute(x, one, options);

      Statistic.draw(x, one, options);
    end
  end
end
