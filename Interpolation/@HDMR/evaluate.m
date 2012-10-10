function values = evaluate(this, newNodes)
  assert(all(all(newNodes >= 0)) && all(all(newNodes <= 1)));

  [ newNodeCount, inputDimension ] = size(newNodes);
  assert(inputDimension == this.inputDimension);

  interpolants = this.interpolants;
  offset = repmat(this.offset, newNodeCount, 1);

  values = offset;

  cache = Map('char');

  %
  % Loop through all the orders of the HDMR algorithm.
  %
  for i = 1:length(interpolants)
    orderInterpolants = interpolants(i);
    orderKeys = orderInterpolants.keys;

    %
    % Loop through all the interpolants of the current order.
    %
    for j = 1:length(orderKeys)
      key = orderKeys{j};
      index = uint16(key);
      cardinality = length(index);

      %
      % Take into consideration the `cardinality'-order interpolant
      % and the correction due to the zero-order interpolant.
      %
      values = values + (-1)^cardinality * offset + ...
        orderInterpolants(key).evaluate(newNodes(:, j));

      %
      % Now, the corrections due to the `cardinality - 1'-order
      % interpolants.
      %
      for k = 1:(i - 1)

      end
    end
  end
end
