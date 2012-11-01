function values = evaluateSet(this, nodes, coefficients)
  rvPower = this.rvPower;
  rvMap = this.rvMap;

  monomialCount = size(rvPower, 1);
  [ nodeCount, rvCount ] = size(nodes);

  assert(rvCount == this.inputCount);

  rvProduct = zeros(nodeCount, monomialCount);

  for i = 1:monomialCount
    rvProduct(:, i) = prod(realpow( ...
      nodes, Utils.replicate(rvPower(i, :), nodeCount, 1)), 2);
  end

  [ ~, secondDimension, thirdDimension ] = size(coefficients);

  values = zeros(nodeCount, secondDimension, thirdDimension);

  for i = 1:thirdDimension
    values(:, :, i) = rvProduct * (rvMap * coefficients(:, :, i));
  end
end
