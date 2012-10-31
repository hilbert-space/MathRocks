function [ nodes, weights ] = constructAdaptive(this, options)
  dimension = options.dimension;
  polynomialOrder = options.order;

  %
  % A `order'-order Gaussian quadrature rule integrates polynomials
  % of order (2 * `order' - 1) exactly. We want to have exactness
  % for polynomials of order (2 * `order'); therefore,
  %
  order = polynomialOrder + 1;

  %
  % The level of accuracy of a sparse grid is not that simple to
  % define. Refer to the following web page for further details:
  %
  % http://people.sc.fsu.edu/~jburkardt/m_src/sandia_sparse/sandia_sparse.html
  %
  % Roughly speaking:
  %
  %   order = 2^(level + 1) - 1
  %   level = log2(order + 1) - 1
  %
  % Hence, we should have something like
  %
  level = ceil(log2(order + 1) - 1);

  options.set('order', order);
  options.set('level', level);

  [ nodes, weights ] = this.constructSparse(options);

  sparseNodeCount = size(nodes, 1);
  tensorNodeCount = order^dimension;

  fprintf('Quadrature: dimension %d, order %d, tensor %d, sparse %d.\n', ...
    dimension, order, tensorNodeCount, sparseNodeCount);

  if sparseNodeCount >= tensorNodeCount
    [ nodes, weights ] = this.constructTensor(options);
    assert(size(nodes, 1) == tensorNodeCount);
  end
end
