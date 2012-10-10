function values = evaluate(this, newNodes)
  assert(all(all(newNodes >= 0)) && all(all(newNodes <= 1)));

  interpolants = this.interpolants;
  inputDimension = this.inputDimension;
  outputDimension = this.outputDimension;

  assert(inputDimension == size(newNodes, 2));

  newNodeCount = size(newNodes, 1);

  offset = repmat(this.offset, newNodeCount, 1);

  values = offset;
  cache = Map('char');

  %
  % Loop through all the interpolants.
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

      assert(~cache.isKey(key));
      cache(key) = orderInterpolants(key).evaluate(newNodes(:, index));

      %
      % Take into consideration the `i'-order interpolant
      % and the correction due to the zero-order interpolant.
      %
      values = values + cache(key) + (-1)^(i - 0) * offset;

      %
      % Now, the corrections due to the low-order interpolants.
      %
      for k = 1:(i - 1)
        lowOrderKeys = char(uint16(combnk(index, k)));
        for l = 1:length(lowOrderKeys)
          lowKey = lowOrderKeys(l, :);
          if ~cache.isKey(lowKey), continue; end
          values = values + (-1)^(i - k) * cache(lowKey);
        end
      end
    end
  end
end
