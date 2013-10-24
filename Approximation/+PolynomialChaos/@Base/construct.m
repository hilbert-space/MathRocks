function [ nodes, norm, projection, evaluation, rvPower, rvMap ] = ...
  construct(this, order, inputCount, options)

  x = sym('x%d', [ 1, inputCount ]);
  assume(x, 'real');

  indexes = Utils.indexTotalOrderSpace(inputCount, order);
  termCount = size(indexes, 1);

  basis1D = this.constructBasis(x(1), order);
  assert(length(basis1D) == order + 1);

  basisND = basis1D(indexes(:, 1));
  for i = 2:inputCount
    basis1D = subs(basis1D, x(i - 1), x(i));
    basisND = basisND .* basis1D(indexes(:, i));
  end

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

  function result_ = evaluateBasisAtNodes(i_)
    f_ = regexprep(char(basisND(i_)), '([\^\*\/])', '.$1');
    f_ = regexprep(f_, '\<x(\d+)\>', 'nodes(:,$1)');
    result_ = eval(f_);
  end

  for i = 1:termCount
    norm(i) = this.computeNormalizationConstant(i, indexes);
    projection(i, :) = evaluateBasisAtNodes(i) .* weights / norm(i);
  end

  a = sym('a%d', [ 1, termCount ]);
  assume(a, 'real');

  [ rvPower, rvMap ] = Utils.decomposePolynomial(sum(a .* basisND), x, a);
  assert(size(rvPower, 1) == termCount);

  rvMap = sparse(rvMap);

  %
  % The evaluation matrix
  %
  % (# of quadrature nodes) x (# of polynomial terms)
  %
  rvProduct = ones(nodeCount, termCount);

  for i = 1:termCount
    for j = find(rvPower(i, :) > 0)
      rvProduct(:, i) = rvProduct(:, i) .* nodes(:, j).^rvPower(i, j);
    end
  end

  evaluation = rvProduct * rvMap;
end
