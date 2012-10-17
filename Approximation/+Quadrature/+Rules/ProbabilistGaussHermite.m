function [ nodes, weights ] = ProbabilistGaussHermite(order)
  [ nodes, weights ] = computeGaussHermite(order);

  %
  % Now, the nodes and weights can be used to compute integrals with
  % the weight function e^(-y^2). However, we need the standard gaussian
  % measure, i.e., (1 / sqrt(2 * pi) * e^(-x^2 / 2); therefore, we
  % perform the following transformation:
  %
  nodes = sqrt(2) * nodes;
  weights = weights / sqrt(pi);
end
