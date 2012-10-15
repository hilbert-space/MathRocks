function value = evaluate(this, coefficients, nodes)
  [ terms, codimension ] = size(coefficients);

  assert(codimension == this.codimension, ...
    'The deterministic dimension is invalid.');
  assert(terms == size(this.rvMap, 2), ...
    'The number of terms is invalid.');

  monomialTerms = size(this.rvPower, 1);
  points = size(nodes, 1);

  rvPower = this.rvPower;
  rvProduct = zeros(points, monomialTerms);
  rvMap = this.rvMap;

  for i = 1:monomialTerms
    rvProduct(:, i) = prod(realpow( ...
      nodes, Utils.replicate(rvPower(i, :), points, 1)), 2);
  end

  value = rvProduct * (rvMap * coefficients);
end
