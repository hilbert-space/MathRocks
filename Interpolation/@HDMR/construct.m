function construct(this, f, options)
  zeros = @uninit;

  inputDimension = options.inputDimension;
  outputDimension = options.get('outputDimension', 1);

  tolerance = options.get('tolerance', 1e-3);
  maxOrder = options.get('maxOrder', 10);
  maxLevel = options.get('maxLevel', 10);

  interpolants = Map('uint32');

  %
  % The zeroth order.
  %
  offset = f(0.5 * ones(1, inputDimension));

  %
  % The first order.
  %
  for i = 1:inputDimension
    interpolants(i) = ASGC( ...
      @(nodes) evaluate(f, nodes, i, inputDimension, offset), ...
      'inputDimension', 1, ...
      'outputDimension', outputDimension, ...
      'tolerance', tolerance, ...
      'maxLevel', maxLevel);
  end

  %
  % Save the result.
  %
  this.inputDimension = inputDimension;
  this.outputDimension = outputDimension;

  this.offset = offset;
  this.interpolants = interpolants;
end

function result = evaluate(f, nodes, index, inputDimension, offset)
  %
  % Reshape the nodes.
  %
  [ nodeCount, nodeDimension ] = size(nodes);
  assert(length(index) == nodeDimension);
  result = 0.5 * ones(nodeCount, inputDimension);
  result(:, index) = nodes;

  %
  % Evaluate the function.
  %
  result = f(result);

  %
  % Shift the result.
  %
  result = bsxfun(@minus, result, offset);
end
