function data = evaluateSet(this, coefficientSet, nodes)
  [ codimension, terms, count ] = size(coefficientSet);

  assert(codimension == this.codimension, 'The deterministic dimension is invalid.');
  assert(terms == length(this.norm), 'The number of terms is invalid.');

  monomialTerms = size(this.rvPower, 2);
  points = size(nodes, 2);

  rvPower = this.rvPower;
  rvProduct = zeros(monomialTerms, points);
  rvMap = this.rvMap;

  for i = 1:monomialTerms
    rvProduct(i, :) = prod(realpow( ...
      nodes, irep(rvPower(:, i), 1, points)), 1);
  end

  data = zeros(points, codimension, count);

  for i = 1:count
    data(:, :, i) = transpose((coefficientSet(:, :, i) * rvMap) * rvProduct);
  end
end
