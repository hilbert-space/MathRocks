function [ globalError, localError ] = compare(varargin)
  [ data, options ] = Options.extract(varargin{:});
  assert(length(data) == 2, ...
    'The comparison is supported only for two sets of data.');

  oneSize = size(data{1});
  twoSize = size(data{2});

  dimensions = length(oneSize);

  assert(dimensions == length(twoSize), ...
    'The dimensions are invalid.');
  assert(dimensions == 2 || dimensions == 3, ...
    'The given number of dimensions is not supported.');

  options = Options('draw', false, 'layout', 'tiles', 'names', {}, ...
    'errorMetric', 'NRMSE', options);

  if ~options.has('distanceMetric');
    options.distanceMetric = options.errorMetric;
  end

  if dimensions == 2
    [ globalError, localError ] = compare2D(data{1}, data{2}, options);
  else
    [ globalError, localError ] = compare3D(data{1}, data{2}, options);
  end
end

function [ globalError, localError ] = compare2D(oneData, twoData, options)
  [ dataCount, dimensionCount ] = size(oneData);
  assert(dimensionCount == size(twoData, 2), 'The dimensions are invalid.');

  if dimensionCount > dataCount
    warning('Suspicious data: %d dimensions > %d data points.', ...
      dimensionCount, dataCount);
  end

  if options.draw
    switch options.layout
    case 'one'
      Plot.figure;
      legend = {};
    case 'tiles'
      Plot.figure;
    case 'separate'
    otherwise
      error('The layout is unknown.');
    end
  end

  localError = zeros(1, dimensionCount);

  for i = 1:dimensionCount
    one = oneData(:, i);
    two = twoData(:, i);

    x = Utils.constructLinearSpace(one, two, options);

    one = Statistic.compute(x, one, options);
    two = Statistic.compute(x, two, options);

    localError(i) = Error.compute(options.distanceMetric, one, two);

    if ~options.draw, continue; end

    switch options.layout
    case 'one'
      styles = { ...
        { 'Color', Color.pick(i) }, ...
        { 'Color', Color.pick(i), 'LineStyle', '--' }};
    case 'tiles'
      subplot(1, dimensionCount, i);
      styles = { ...
        { 'Color', Color.pick(1) }, ...
        { 'Color', Color.pick(2) }};
    case 'separate'
      Plot.figure;
      styles = { ...
        { 'Color', Color.pick(1) }, ...
        { 'Color', Color.pick(2) }};
    end

    Statistic.draw(x, one, two, options, 'styles', styles);

    switch options.layout
    case 'one'
      legend{end + 1} = sprintf('%d', i);
      legend{end + 1} = sprintf('%d: %s %.4f', ...
        i, options.distanceMetric, localError(i));
      if ~isempty(options.names)
        legend{end - 1} = [ options.names{1}, ' ', legend{end - 1} ];
        legend{end - 0} = [ options.names{2}, ' ', legend{end - 0} ];
      end
    case { 'tiles', 'separate' }
      Plot.title('Distribution %d: %s %.4f', i, ...
        options.distanceMetric, localError(i));
      Plot.legend(options.names{:});
    end
  end

  switch options.layout
  case 'one'
    Plot.title('Distribution');
    Plot.legend(legend{:});
  end

  globalError = mean(localError(:));
end

function [ globalError, localError ] = compare3D(oneData, twoData, options)
  [ ~, dimensionCount, codimensionCount ] = size(oneData);
  assert(dimensionCount == size(twoData, 2) && ...
    codimensionCount == size(twoData, 3), ...
    'The dimensions are invalid.');

  draw = options.draw;
  options = Options(options, 'draw', false);

  localError = zeros(dimensionCount, codimensionCount);

  if matlabpool('size') > 0
    h = Bar(sprintf('Comparison of %d steps in parallel...', codimensionCount), 100, 50);
    parfor i = 1:codimensionCount
      [ ~, localError(:, i) ] = compare2D( ...
        oneData(:, :, i), twoData(:, :, i), options);
    end
    close(h);
  else
    h = Bar('Comparison: step %d out of %d.', codimensionCount);
    for i = 1:codimensionCount
      [ ~, localError(:, i) ] = compare2D( ...
        oneData(:, :, i), twoData(:, :, i), options);
      increase(h);
    end
  end

  globalError = mean(localError(:));

  if ~draw, return; end

  Plot.figure;

  oneExp = squeeze(mean(oneData, 1));
  twoExp = squeeze(mean(twoData, 1));
  expectationError = abs(oneExp - twoExp);

  oneVar = squeeze(var(oneData, [], 1));
  twoVar = squeeze(var(twoData, [], 1));
  varianceError = abs(oneVar - twoVar);

  time = 0:(codimensionCount - 1);

  subplot(1, 3, 1);
  Plot.title('Expectation (%s %.4f)', options.errorMetric, ...
    Error.compute(options.errorMetric, oneExp, twoExp));
  Plot.label('', 'Absolute error');
  Plot.limit(time);

  subplot(1, 3, 2);
  Plot.title('Variance (%s %.4f)', options.errorMetric, ...
    Error.compute(options.errorMetric, oneVar, twoVar));
  Plot.label('', 'Absolute error');
  Plot.limit(time);

  subplot(1, 3, 3);
  Plot.title('Distribution (mean %.4f)', globalError);
  Plot.label('', options.distanceMetric);
  Plot.limit(time);

  Plot.name('Errors of empirical expectation, variance, and distribution');

  for i = 1:dimensionCount
    color = Color.pick(i);
    subplot(1, 3, 1);
    line(time, expectationError(i, :), 'Color', color);
    subplot(1, 3, 2);
    line(time, varianceError(i, :), 'Color', color);
    subplot(1, 3, 3);
    line(time, localError(i, :), 'Color', color);
  end
end
