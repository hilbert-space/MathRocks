function construct(this, f, options)
  inputDimension = options.inputDimension;
  outputDimension = options.get('outputDimension', 1);

  tolerance = options.get('tolerance', 1e-3);

  maxOrder = options.get('maxOrder', 10);
  maxLevel = options.get('maxLevel', 10);

  interpolants = Map('char');
  nodeCount = 1; % Due to the zeroth order below.

  %
  % The zeroth order.
  %
  offset = f(0.5 * ones(1, inputDimension));

  %
  % The first and other orders.
  %
  order = 1;
  while true
    orderIndex = uint16(combnk(1:inputDimension, order));

    for i = 1:size(orderIndex, 1)
      index = orderIndex(i, :);
      key = char(index);

      %
      % Make sure we do not do anything bad.
      %
      assert(~interpolants.isKey(key));

      %
      % We need to subtract the low-lever interpolants.
      %
      [ lowIndex, lowInterpolants ] = ...
        selectLowInterpolants(interpolants, order, index);

      interpolants(key) = ASGC(@(cutNodes) compute(f, cutNodes, ...
        index, inputDimension, order, offset, lowIndex, lowInterpolants), ...
        'inputDimension', order, 'outputDimension', outputDimension, ...
        'tolerance', tolerance, 'maxLevel', maxLevel);

      nodeCount = nodeCount + interpolants(key).nodeCount;
    end

    if order == maxOrder, break; end
    order = order + 1;
  end

  %
  % Save the result.
  %
  this.inputDimension = inputDimension;
  this.outputDimension = outputDimension;

  this.order = order;
  this.nodeCount = nodeCount;

  this.offset = offset;
  this.interpolants = interpolants;
end

function values = compute(f, cutNodes, index, inputDimension, ...
  order, offset, lowIndex, lowInterpolants)

  nodeCount = size(cutNodes, 1);

  %
  % The central point is the mean of the standard uniform distribution.
  %
  nodes = 0.5 * ones(nodeCount, inputDimension);
  nodes(:, index) = cutNodes;

  values = f(nodes);

  %
  % Take care about the zeroth order.
  %
  values = bsxfun(@minus, values, offset);

  %
  % Take care about the orders from one to `order - 1'.
  %
  for i = 1:length(lowIndex)
    index = lowIndex{i};
    values = values - lowInterpolants{i}.evaluate(nodes(:, index));
  end
end

function [ lowIndex, lowInterpolants ] = ...
  selectLowInterpolants(interpolants, order, index)

  variableCount = length(index);
  interpolantCount = 0;

  %
  % Count the numer of possible interpolants.
  %
  for i = 1:(order - 1)
    interpolantCount = interpolantCount + nchoosek(variableCount, i);
  end

  lowIndex = cell(1, interpolantCount);
  lowInterpolants = cell(1, interpolantCount);

  k = 0;

  for i = 1:(order - 1)
    keys = char(uint16(combnk(index, i)));
    for j = 1:size(keys, 1)
      key = keys(j, :);

      if ~interpolants.isKey(key), continue; end

      k = k + 1;
      assert(k <= interpolantCount);

      lowIndex{k} = uint16(key);
      lowInterpolants{k} = interpolants(key);
    end
  end

  %
  % Cut if we have counted too many.
  %
  lowIndex = lowIndex(1:k);
  lowInterpolants = lowInterpolants(1:k);
end
