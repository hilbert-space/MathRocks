function values = evaluate(this, output, nodes)
  rvPower = this.rvPower;
  rvMap = this.rvMap;

  monomialCount = size(rvPower, 1);
  [ nodeCount, rvCount ] = size(nodes);

  assert(rvCount == this.inputCount);

  rvProduct = zeros(nodeCount, monomialCount);

  for i = 1:monomialCount
    rvProduct(:, i) = prod(realpow( ...
      nodes, repmat(rvPower(i, :), [ nodeCount, 1 ])), 2);
  end

  coefficients = output.coefficients;
  dimensions = size(coefficients);

  switch length(dimensions)
  case 2
    values = rvProduct * (rvMap * coefficients);
  case 3
    values = zeros(nodeCount, dimensions(2), dimensions(3));
    for i = 1:dimensions(3)
      values(:, :, i) = rvProduct * (rvMap * coefficients(:, :, i));
    end
  otherwise
    assert(false);
  end
end
