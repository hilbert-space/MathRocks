function construct(this, f, options)
  zeros = @uninit;

  inputDimension = options.inputDimension;
  outputDimension = options.get('outputDimension', 1);

  tolerance = options.get('tolerance', 1e-3);

  minOrder = options.get('minOrder', 1);
  maxOrder = options.get('maxOrder', 10);

  minLevel = options.get('minLevel', 2);
  maxLevel = options.get('maxLevel', 10);

  interpolants = Map('uint32');

  %
  % The zeroth order.
  %
  offset = f(0.5 * ones(1, inputDimension));

  %
  % The first and other orders.
  %
  order = 1;
  while order <= maxOrder
    orderIndex = uint16(combnk(1:inputDimension, order));

    orderInterpolants = Map('char');
    for i = 1:size(orderIndex, 1)
      index = orderIndex(i, :);
      key = char(index);
      orderInterpolants(key) = ASGC( ...
        @(nodes) evaluate(f, nodes, index, inputDimension), ...
        'inputDimension', order, 'outputDimension', outputDimension, ...
        'tolerance', tolerance, 'maxLevel', maxLevel);
    end
    interpolants(order) = orderInterpolants;

    order = order + 1;
  end

  %
  % Save the result.
  %
  this.inputDimension = inputDimension;
  this.outputDimension = outputDimension;

  this.offset = offset;
  this.interpolants = interpolants;
end

function result = evaluate(f, nodes, index, inputDimension)

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
end
