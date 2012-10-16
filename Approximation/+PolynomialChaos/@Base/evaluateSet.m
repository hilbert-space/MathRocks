function data = evaluateSet(this, coefficientSet, nodes)
  [ codimension, terms, count ] = size(coefficientSet);

  assert(terms == length(this.norm), ...
    'The number of terms is invalid.');

  monomialTerms = size(this.rvPower, 1);
  points = size(nodes, 1);

  rvPower = this.rvPower;
  rvProduct = zeros(points, monomialTerms);
  rvMap = this.rvMap;

  for i = 1:monomialTerms
    rvProduct(:, i) = prod(realpow( ...
      nodes, irep(rvPower(i, :), points, 1)), 2);
  end

  data = zeros(points, codimension, count);

  for i = 1:count
    data(:, :, i) = rvProduct * (rvMap * coefficientSet(:, :, i));
  end
end
