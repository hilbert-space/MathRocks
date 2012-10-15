function [ nodes, norm, projectionMatrix, evaluationMatrix, rvPower, rvMap ] = ...
  construct(this, options)

  dimension = options.dimension;
  codimension = options.codimension;
  order = this.order;

  %
  % Construct the RVs.
  %
  for i = 1:dimension
    x(i) = sympoly([ 'x', num2str(i) ]);
  end

  %
  % Compute the multi-index.
  %
  index = Utils.constructMultiIndex( ...
    dimension, order, [], options.method) + 1;

  %
  % Construct the corresponding multivariate basis.
  %
  basis = this.constructBasis(x, order, index);

  terms = length(basis);

  %
  % Now, the quadrature rule.
  %
  qd = Quadrature.(options.quadratureName)( ...
    'dimension', dimension, options.quadratureOptions);

  points = qd.points;
  nodes = transpose(qd.nodes);
  weights = transpose(qd.weights);

  projectionMatrix = zeros(points, terms);
  norm = zeros(1, terms);

  for i = 1:terms
    f = Utils.toFunction(basis(i), x, 'rows');
    norm(i) = this.computeNormalizationConstant(i, index);
    projectionMatrix(:, i) = f(nodes) .* weights / norm(i);
  end

  %
  % Construct the overall polynomial with abstract coefficients
  % and produce its representation in terms of monomials.
  %
  for i = 1:terms
    a(i) = sympoly([ 'a', num2str(i) ]);
  end

  %
  % rvPower is a (dimension x monomial terms) matrix of the exponents
  % of each of the RVs in each of the monomials.
  %
  % rvMap is a (expansion terms x monomial terms) matrix that maps
  % the PC expansion coefficients to the coefficients of the monomials.
  %
  [ rvPower, rvMap ] = Utils.toMatrix(sum(a .* basis));

  monomialTerms = size(rvPower, 2);

  %
  % rvProduct is a (monomial terms x integration points) matrix that
  % contains the monomials evaluated at each node of the grid.
  %
  rvProduct = zeros(monomialTerms, points);

  for i = 1:monomialTerms
    rvProduct(i, :) = prod(realpow(nodes, ...
      Utils.replicate(rvPower(:, i), 1, points)), 1);
  end

  evaluationMatrix = rvMap * rvProduct;
end
