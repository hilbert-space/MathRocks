function [ nodes, norm, projection, evaluation, rvPower, rvMap ] = ...
  construct(this, order, inputCount, options)

  x = sym('x%d', [ 1, inputCount ]);
  assume(x, 'real');

  indexes = Utils.indexTotalOrderSpace(inputCount, order);

  basis = this.constructBasis(x, order, indexes);
  termCount = length(basis);

  quadrature = this.constructQuadrature(order, ...
    options.get('quadratureOptions', []));

  nodes = quadrature.nodes;
  weights = quadrature.weights;
  nodeCount = quadrature.nodeCount;

  %
  % The projection matrix
  %
  % (# of polynomial terms) x (# of quadrature nodes)
  %
  projection = zeros(termCount, nodeCount);
  norm = zeros(termCount, 1);

  for i = 1:termCount
    f = Utils.pointwiseFunction(basis(i), x);
    norm(i) = this.computeNormalizationConstant(i, indexes);
    projection(i, :) = f(nodes) .* weights / norm(i);
  end

  a = sym('a%d', [ 1, termCount ]);
  assume(a, 'real');

  [ rvPower, rvMap ] = Utils.decomposePolynomial(sum(a .* basis), x, a);
  assert(size(rvPower, 1) == termCount);

  %
  % The evaluation matrix
  %
  % (# of quadrature nodes) x (# of polynomial terms)
  %
  rvProduct = zeros(nodeCount, termCount);

  for i = 1:termCount
    rvProduct(:, i) = prod(realpow( ...
      nodes, repmat(rvPower(i, :), [ nodeCount, 1 ])), 2);
  end

  evaluation = rvProduct * rvMap;
end
