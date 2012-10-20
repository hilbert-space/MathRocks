function values = evaluate(this, nodes)
  coefficients = this.coefficients;
  rvPower = this.rvPower;
  rvMap = this.rvMap;

  terms = size(coefficients, 1);
  monomialTerms = size(rvPower, 1);
  points = size(nodes, 1);

  rvProduct = zeros(points, monomialTerms);

  for i = 1:monomialTerms
    rvProduct(:, i) = prod(realpow( ...
      nodes, Utils.replicate(rvPower(i, :), points, 1)), 2);
  end

  values = rvProduct * (rvMap * coefficients);
end
