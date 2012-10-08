function [ globalError, localError ] = compareData(varargin)
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

  if draw, figure; end

  localError = zeros(1, dimension);

  for i = 1:dimension
    if draw, p = subplot(1, dimension, i); end

    onedata = oneData(:, i);
    twodata = twoData(:, i);

    x = constructLinearSpace(onedata, twodata, options);

    [ mcx, oneData ] = processData(x, onedata, options);
    [ sdx, twoData ] = processData(x, twodata, options);

    assert(nnz(mcx - sdx) == 0, 'The supports are invalid.');

    localError(i) = computeNRMSE(oneData, twoData);

    if draw
      drawData(mcx, oneData, twoData, options);
      title(sprintf('NRMSE %.2f %%', localError(i) * 100));
      labels = options.get('labels', {});
      legend(labels{:});
    end
  end

  globalError = sqrt(sum(localError .^ 2) / dimension);
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
    [ ~, localError(:, i) ] = compare2D(oneData(:, :, i), twoData(:, :, i), options);
    increase(h);
  end

  globalError = sqrt(sum(localError(:) .^ 2) / (dimension * codimension));

  if ~draw, return; end

  figure;

  labels = {};
  time = 0:(codimension - 1);

  for i = 1:dimension
    labels{end + 1} = num2str(i);
    line(time, localError(i, :) * 100, 'Color', Color.pick(i));
  end

  title('Error evolution');
  ylabel('NRMSE, %');
  legend(labels{:});
end
