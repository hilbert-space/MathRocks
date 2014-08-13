function values = evaluate(this, output, nodes, isUniform)
  if nargin > 3 && isUniform
    nodes = this.distribution.icdf(nodes);
  end

  rvPower = this.rvPower;

  termCount = this.termCount;
  [nodeCount, rvCount] = size(nodes);

  assert(rvCount == this.inputCount);

  rvProduct = ones(nodeCount, termCount);
  for i = 1:termCount
    for j = find(rvPower(i, :) > 0)
      rvProduct(:, i) = rvProduct(:, i) .* nodes(:, j).^rvPower(i, j);
    end
  end

  values = rvProduct * (this.rvMap * output.coefficients);
end
