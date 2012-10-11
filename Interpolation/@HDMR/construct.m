function construct(this, f, options)
  inputDimension = options.inputDimension;
  outputDimension = options.get('outputDimension', 1);

  orderTolerance = options.get('orderTolerance', 1e-2);
  dimensionTolerance = options.get('dimensionTolerance', 1e-2);
  maxOrder = options.get('maxOrder', 10);

  interpolantOptions = Options( ...
    'tolerance', 1e-4, ...
    'maxLevel', 10, ...
    options.get('interpolantOptions', []), ...
    'outputDimension', outputDimension, ...
    'inputDimension', 1);

  interpolants = Map('char');
  nodeCount = 1; % Due to the zeroth order below.

  %
  % Adaptivity control.
  %
  refine = Map('char', 'logical');

  %
  % The zeroth order.
  %
  offset = f(0.5 * ones(1, inputDimension));
  expectation = offset;

  %
  % The first and other orders.
  %
  order = 1;
  orderIndex = combnk(uint16(1:inputDimension), order);
  while true
    %
    % Adaptivity control.
    %
    groundNorm = norm(expectation);
    refinemendIsNeeded = false;

    orderExpectation = zeros(1, outputDimension);

    for i = 1:size(orderIndex, 1)
      index = orderIndex(i, :);
      key = char(index);

      %
      % We need to subtract the low-lever interpolants.
      %
      [ lowIndex, lowInterpolants ] = ...
        selectLowInterpolants(interpolants, order, index);

      interpolantOptions.inputDimension = order;
      newInterpolant = ASGC(@(cutNodes) compute(f, cutNodes, ...
        index, inputDimension, order, offset, lowIndex, lowInterpolants), ...
        interpolantOptions);

      %
      % Adaptivity control.
      %
      dimensionImportance = ...
        norm(newInterpolant.expectation) / groundNorm;

      if dimensionImportance == 0.0
        %
        % If it is exactly zero, there will probably be no contribution
        % from the interpolant. However, it introduces new points
        % to consider in the future; skip it for now.
        %
        continue;
      elseif dimensionImportance >= dimensionTolerance
        refine(key) = true;
        refinemendIsNeeded = true;
      end

      %
      % Keep track of the statistics.
      %
      nodeCount = nodeCount + newInterpolant.nodeCount;
      orderExpectation = ...
        orderExpectation + newInterpolant.expectation;

      assert(~interpolants.isKey(key));
      interpolants(key) = newInterpolant;
    end

    %
    % Adaptivity control FIRST.
    %
    orderBenefit = norm(orderExpectation) / norm(expectation);

    %
    % Advance the expectation ONLY after the step above.
    %
    expectation = expectation + orderExpectation;

    %
    % How to stop?
    %
    % 1. The maximal order is reached.
    % 2. The gain from the order is too small.
    % 3. There have not been identified any `inaccurate' indexes.
    %

    if ...
      (order == maxOrder) || ...
      (orderBenefit < orderTolerance) || ...
      ~refinemendIsNeeded, break; end

    %
    % Go to the next order.
    %
    order = order + 1;
    orderIndex = constructOrderIndex(inputDimension, order, refine);
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

  this.expectation = expectation;
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
    keys = char(combnk(index, i));
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

function orderIndex = constructOrderIndex(inputDimension, order, refine)
  %
  % All possible multi-indexes of order `order'.
  %
  orderIndex = combnk(uint16(1:inputDimension), order);

  %
  % Now, we need to check each index whether it is admissible,
  % e.g., whether all its subindexes belong to the refinement map.
  %

  totalCount = size(orderIndex, 1);
  invalid = logical(zeros(totalCount, 1));

  %
  % For all candidate indexes.
  %
  for i = 1:totalCount
    %
    % For all low orders.
    %
    for j = 1:(order - 1)
      %
      % All possible multi-indexes of order `j'.
      %
      lowOrderIndex = combnk(orderIndex(i, :), j);

      %
      % For all low-dimensional indexes.
      %
      for k = 1:size(lowOrderIndex, 1)
        if ~refine.isKey(char(lowOrderIndex(k, :)))
          invalid(i) = true;
          break;
        end
      end

      if invalid(i), break; end
    end
  end

  orderIndex(invalid, :) = [];
end
