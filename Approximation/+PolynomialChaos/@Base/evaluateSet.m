function data = evaluateSet(this, coefficientSet, nodes)
  [ codimension, terms, count ] = size(coefficientSet);

  rvPower = this.rvPower;
  rvMap = this.rvMap;

  assert(terms == size(rvMap, 2), ...
    'The number of terms is invalid.');

  monomialTerms = size(rvPower, 1);
  points = size(nodes, 1);

  rvProduct = zeros(points, monomialTerms);

  for i = 1:monomialTerms
    rvProduct(:, i) = prod(realpow( ...
      nodes, irep(rvPower(i, :), points, 1)), 2);
  end

  data = zeros(points, codimension, count);

  for i = 1:count
    data(:, :, i) = rvProduct * (rvMap * coefficientSet(:, :, i));
  end
end
