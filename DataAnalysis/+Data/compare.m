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

  if dimensions == 2
    [ globalError, localError ] = compare2D(data{1}, data{2}, options);
  else
    [ globalError, localError ] = compare3D(data{1}, data{2}, options);
  end
end

function [ globalError, localError ] = compare2D(oneData, twoData, options)
  [ ~, dimension ] = size(oneData);
  assert(dimension == size(twoData, 2), 'The dimensions are invalid.');

  draw = options.get('draw', false);

  if draw
    layout = options.get('layout', 'tiles');
    switch layout
    case 'tiles'
      figure;
    case 'separate'
    otherwise
      error('The layout is unknown.');
    end
  end

  localError = zeros(1, dimension);

  for i = 1:dimension
    one = oneData(:, i);
    two = twoData(:, i);

    x = Utils.constructLinearSpace(one, two, options);

    one = Data.process(x, one, options);
    two = Data.process(x, two, options);

    localError(i) = Error.computeRMSE(one, two);

    if ~draw, continue; end

    switch layout
    case 'tiles'
      subplot(1, dimension, i);
    case 'separate'
      figure;
    end

    Data.draw(x, one, two, options);
    Plot.title('Dimension %d (RMSE %.2f)', i, localError(i));
    labels = options.get('labels', {});
    Plot.legend(labels{:});
  end

  globalError = Error.computeRMSE(localError);
end

function [ globalError, localError ] = compare3D(oneData, twoData, options)
  [ ~, dimension, codimension ] = size(oneData);
  assert(dimension == size(twoData, 2) && codimension == size(twoData, 3), ...
    'The dimensions are invalid.');

  draw = options.get('draw', false);
  options.update('draw', false);

  h = Bar('Comparison: step %d out of %d.', codimension);

  localError = zeros(dimension, codimension);

  for i = 1:codimension
    [ ~, localError(:, i) ] = compare2D( ...
      oneData(:, :, i), twoData(:, :, i), options);
    increase(h);
  end

  globalError = Error.computeRMSE(localError);

  if ~draw, return; end

  figure;

  labels = {};
  time = 0:(codimension - 1);

  for i = 1:dimension
    labels{end + 1} = num2str(i);
    line(time, localError(i, :), 'Color', Color.pick(i));
  end

  Plot.title('Error evolution');
  Plot.label('', 'RMSE');
  legend(labels{:});
end
