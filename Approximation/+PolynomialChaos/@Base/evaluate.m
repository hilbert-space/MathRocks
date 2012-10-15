function value = evaluate(this, coefficients, nodes)
  [ codimension, terms ] = size(coefficients);

  assert(codimension == this.codimension, 'The deterministic dimension is invalid.');
  assert(terms == size(this.rvMap, 1), 'The number of terms is invalid.');

  monomialTerms = size(this.rvPower, 2);
  points = size(nodes, 2);

  rvPower = this.rvPower;
  rvProduct = zeros(monomialTerms, points);
  rvMap = this.rvMap;

  for i = 1:monomialTerms
    rvProduct(i, :) = prod(realpow( ...
      nodes, Utils.replicate(rvPower(:, i), 1, points)), 1);
  end

  value = (coefficients * rvMap) * rvProduct;
end
