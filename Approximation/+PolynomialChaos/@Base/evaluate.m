function values = evaluate(this, nodes, coefficients)
  if nargin < 3, coefficients = this.coefficients; end

  rvPower = this.rvPower;
  rvMap = this.rvMap;

  monomialCount = size(rvPower, 1);
  nodeCount = size(nodes, 1);

  rvProduct = zeros(nodeCount, monomialCount);

  for i = 1:monomialCount
    rvProduct(:, i) = prod(realpow( ...
      nodes, Utils.replicate(rvPower(i, :), nodeCount, 1)), 2);
  end

  values = rvProduct * (rvMap * coefficients);
end
