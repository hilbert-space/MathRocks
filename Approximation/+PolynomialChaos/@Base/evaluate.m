function value = evaluate(this, coefficients, nodes)
  terms = size(coefficients, 1);

  assert(terms == size(this.rvMap, 2), ...
    'The number of terms is invalid.');

  rvPower = this.rvPower;
  rvMap = this.rvMap;

  monomialTerms = size(rvPower, 1);
  points = size(nodes, 1);

  rvProduct = zeros(points, monomialTerms);

  for i = 1:monomialTerms
    rvProduct(:, i) = prod(realpow( ...
      nodes, Utils.replicate(rvPower(i, :), points, 1)), 2);
  end

  value = rvProduct * (rvMap * coefficients);
end
