function construct(this, f, options)
  inputDimension = options.inputDimension;
  outputDimension = options.get('outputDimension', 1);

  orderTolerance = options.get('orderTolerance', 1e-2);
  dimensionTolerance = options.get('dimensionTolerance', 1e-2);
  maxOrder = min(options.get('maximalOrder', 10), inputDimension);

  interpolantOptions = Options( ...
    'tolerance', 1e-4, ...
    'maximalLevel', 10, ...
    options.get('interpolantOptions', []), ...
    'outputDimension', outputDimension, ...
    'inputDimension', 1);

  verbose = @(varargin) [];
  if options.get('verbose', false)
    verbose = @(varargin) fprintf(varargin{:});
  end

  interpolants = Map('char');

  %
  % Adaptivity control.
  %
  refine = Map('char', 'logical');

  %
  % The zeroth order.
  %
  offset = f(0.5 * ones(1, inputDimension));
  offset2 = offset.^2;

  expectation = offset;
  secondRawMoment = offset2;

  %
  % NOTE: Count the evaluation above.
  %
  nodeCount = 1;

  %
  % The first and other orders.
  %
  order = 1;
  orderIndex = combnk(uint16(1:inputDimension), order);
  while true
    verbose('Order %2d, index %6d, interpolants %6d.\n', ...
      order, size(orderIndex, 1), length(interpolants));

    %
    % Adaptivity control.
    %
    refinemendIsNeeded = false;
    expectationNorm = norm(expectation);
    assert(expectationNorm > 0);

    orderExpectation = zeros(1, outputDimension);
    orderSecondRawMoment = orderExpectation;

    for i = 1:size(orderIndex, 1)
      index = orderIndex(i, :);
      key = char(index);

      %
      % First, we construct an interpolant for the dimensions
      % selected by `index'.
      %
      interpolantOptions.inputDimension = order;
      newInterpolant = ASGC(@(cutNodes) compute(f, cutNodes, ...
        index, inputDimension), interpolantOptions);

      %
      % Now, we need to evaluate the contribution of the interpolant.
      % The contribution is defined as a ratio between the norm of the
      % expected value of the new interpolant and the norm of the expected
      % expected value of the overall interpolant constructed so far.
      % Therefore, as the first step, we need to find all such low-order
      % interpolants with respect to the intex of the new interpolant.
      % Also, we keep track of the variance.
      %

      %
      % The stats of the new and the zero-order interpolants.
      %
      sign = (-1)^(order - 0);
      newExpectation = newInterpolant.expectation + sign * offset;
      newSecondRawMoment = newInterpolant.secondRawMoment + sign * offset2;

      %
      % The rest of the low-order interpolants.
      %
      lowKeys = selectLowKeys(interpolants, order, index);
      for j = 1:length(lowKeys)
        sign = (-1)^(order - length(lowKeys{j}));
        lowInterpolant = interpolants(lowKeys{j});
        newExpectation = newExpectation + ...
          sign * lowInterpolant.expectation;
        newSecondRawMoment = newSecondRawMoment + ...
          sign * lowInterpolant.secondRawMoment;
      end

      %
      % Adaptivity control.
      %
      dimensionContribution = norm(newExpectation) / expectationNorm;

      if dimensionContribution == 0.0
        %
        % If it is exactly zero, there will probably be no contribution
        % from the interpolant. However, it introduces new points
        % to consider in the future; skip it for now.
        %
        continue;
      elseif dimensionContribution >= dimensionTolerance
        refine(key) = true;
        refinemendIsNeeded = true;
      end

      %
      % Keep track of the statistics.
      %
      nodeCount = nodeCount + newInterpolant.nodeCount;
      orderExpectation = orderExpectation + newExpectation;
      orderSecondRawMoment = orderSecondRawMoment + newSecondRawMoment;

      assert(~interpolants.isKey(key));
      interpolants(key) = newInterpolant;
    end

    %
    % Advance the expectation and variance.
    %
    expectation = expectation + orderExpectation;
    secondRawMoment = secondRawMoment + orderSecondRawMoment;

    %
    % How to stop?
    %
    % 1. The maximal order is reached.
    %
    if (order + 1) > maxOrder, break; end
    %
    % 2. The contribution of the order is too small.
    %
    orderContribution = norm(orderExpectation) / expectationNorm;
    if orderContribution < orderTolerance, break; end
    %
    % 3. There have not been found any `inaccurate' dimensions.
    %
    if ~refinemendIsNeeded, break; end

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
  this.variance = secondRawMoment - expectation.^2;
end

function values = compute(f, cutNodes, index, inputDimension)
  nodeCount = size(cutNodes, 1);

  %
  % The central point is the mean of the standard uniform distribution.
  %
  nodes = 0.5 * ones(nodeCount, inputDimension);
  nodes(:, index) = cutNodes;

  values = f(nodes);
end

function orderIndex = constructOrderIndex(inputDimension, order, refine)
  %
  % All possible multi-indices of order `order'.
  %
  orderIndex = combnk(uint16(1:inputDimension), order);

  %
  % Now, we need to check each index whether it is admissible,
  % e.g., whether all its subindices belong to the refinement map.
  %

  totalCount = size(orderIndex, 1);
  invalid = logical(zeros(totalCount, 1));

  %
  % For all candidate indices.
  %
  for i = 1:totalCount
    %
    % For all low orders.
    %
    for j = 1:(order - 1)
      %
      % All possible multi-indices of order `j'.
      %
      lowOrderIndex = combnk(orderIndex(i, :), j);

      %
      % For all low-dimensional indices.
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
