function [ globalError, localError ] = compareDistributions(Y1, Y2, varargin)
  options = Options('draw', nargout == 0, 'layout', 'tiles', 'names', {}, ...
    'errorMetric', 'RMSE', 'distanceMetric', 'KLD', varargin{:});

  size1 = size(Y1);
  size2 = size(Y2);

  dimensions = length(size1);

  assert(dimensions == length(size2));
  assert(dimensions == 2 || dimensions == 3);

  if dimensions == 2
    [ globalError, localError ] = compare2D(Y1, Y2, options);
  else
    [ globalError, localError ] = compare3D(Y1, Y2, options);
  end
end

function [ globalError, localError ] = compare2D(Y1, Y2, options)
  dimensionCount = size(Y1, 2);
  assert(dimensionCount == size(Y2, 2));

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
    y1 = Y1(:, i);
    y2 = Y2(:, i);

    x = Utils.constructLinearSpace({ y1, y2 }, options);

    y1 = Utils.computeDistribution(y1, x, options);
    y2 = Utils.computeDistribution(y2, x, options);

    localError(i) = Error.compute(options.distanceMetric, y1, y2);

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

    Plot.statistic(x, { y1, y2 }, options, 'styles', styles);

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
      Plot.legend(options.names);
    end
  end

  switch options.layout
  case 'one'
    Plot.title('Distribution');
    Plot.legend(legend{:});
  end

  globalError = mean(localError(:));
end

function [ globalError, localError ] = compare3D(Y1, Y2, options)
  [ ~, dimensionCount, codimensionCount ] = size(Y1);
  assert(dimensionCount == size(Y2, 2) && codimensionCount == size(Y2, 3));

  draw = options.draw;
  options = Options(options, 'draw', false);

  localError = zeros(dimensionCount, codimensionCount);

  if isempty(gcp('nocreate'))
    h = Bar('Comparing the distributions at step %d out of %d...', codimensionCount);
    for i = 1:codimensionCount
      [ ~, localError(:, i) ] = compare2D(Y1(:, :, i), Y2(:, :, i), options);
      h.increase;
    end
  else
    h = Bar(sprintf('Comparing the distributions at %d steps in parallel...', ...
      codimensionCount), 100, 50);
    parfor i = 1:codimensionCount
      [ ~, localError(:, i) ] = compare2D(Y1(:, :, i), Y2(:, :, i), options);
    end
    close(h);
  end

  globalError = mean(localError(:));

  if ~draw, return; end

  Plot.figure(1200, 400);

  oneExp = reshape(mean(Y1, 1), dimensionCount, codimensionCount);
  twoExp = reshape(mean(Y2, 1), dimensionCount, codimensionCount);
  expectationError = abs(oneExp - twoExp);

  oneVar = reshape(var(Y1, [], 1), dimensionCount, codimensionCount);
  twoVar = reshape(var(Y2, [], 1), dimensionCount, codimensionCount);
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
  Plot.title('Distribution (%s %.4f)', ...
    options.distanceMetric, globalError);
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
