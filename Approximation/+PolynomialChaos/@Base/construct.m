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
  % Compute the multi-indices.
  %
  index = Utils.constructMultiIndex( ...
    dimension, order, [], options.method) + 1;

  %
  % Construct the corresponding multivariate basis functions.
  %
  basis = this.constructBasis(x, order, index);

  terms = length(basis);

  %
  % Now, the quadrature rule.
  %
  qd = Quadrature.(options.quadratureName)( ...
    'dimension', dimension, options.quadratureOptions);

  points = qd.points;
  nodes = qd.nodes;
  weights = qd.weights;

  %
  % The projection matrix.
  %
  % A (# of polynomial terms) x (# of integration nodes) matrix.
  %
  projectionMatrix = zeros(terms, points);

  norm = zeros(terms, 1);

  for i = 1:terms
    f = Utils.toFunction(basis(i), x, 'columns');
    norm(i) = this.computeNormalizationConstant(i, index);
    projectionMatrix(i, :) = f(nodes) .* weights / norm(i);
  end

  %
  % Construct the overall polynomial with abstract coefficients.
  %
  for i = 1:terms
    a(i) = sympoly([ 'a', num2str(i) ]);
  end

  %
  % Express the polynomial in terms of its monomials.
  %
  % A (# of monomial terms) x (# of stochastic dimension) matrix
  % of the exponents of each of the RVs in each of the monomials.
  %
  % A (# of monomial terms) x (# of polynomial terms) matrix that
  % maps the PC expansion coefficients to the coefficients of
  % the monomials.
  %
  [ rvPower, rvMap ] = Utils.toMatrix(sum(a .* basis));

  monomialTerms = size(rvPower, 1);

  %
  % A (# of integration points x # of monomial terms) matrix that
  % contains the monomials evaluated at each node of the grid.
  %
  rvProduct = zeros(points, monomialTerms);

  for i = 1:monomialTerms
    rvProduct(:, i) = prod(realpow(nodes, ...
      Utils.replicate(rvPower(i, :), points, 1)), 2);
  end

  %
  % The evaluation matrix.
  %
  % A (# of integration nodes) x (# of polynomial terms) matrix.
  %
  evaluationMatrix = rvProduct * rvMap;
end
