function [ nodes, weights ] = constructAdaptive(this, options)
  dimension = options.dimension;
  polynomialOrder = options.polynomialOrder;

  %
  % A `order'-order Gaussian quadrature rule integrates polynomials
  % of order (2 * `order' - 1) exactly. We want to have exactness
  % for polynomials of order (2 * `order'); therefore,
  %
  order = polynomialOrder + 1;

  options.set('order', order);

  [ nodes, weights ] = this.constructSparse(options);

  sparseNodeCount = size(nodes, 1);
  tensorNodeCount = order^dimension;

  % fprintf('Quadrature: dimension %d, order %d, tensor %d, sparse %d.\n', ...
  %   dimension, order, tensorNodeCount, sparseNodeCount);

  if sparseNodeCount >= tensorNodeCount
    [ nodes, weights ] = this.constructTensor(options);
    assert(size(nodes, 1) == tensorNodeCount);
  end
end
