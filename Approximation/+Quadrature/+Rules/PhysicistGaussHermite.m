function [ nodes, weights ] = PhysicistGaussHermite(order)
  [ nodes, weights ] = computeGaussHermite(order);

  %
  % Now, the nodes and weights can be used to compute integrals with
  % the weight function e^(-y^2). However, we need the gaussian
  % measure with the variance 1 / 2, i.e., (1 / sqrt(pi) * e^(-x^2);
  % therefore, we perform the following transformation:
  %
  weights = weights / sqrt(pi);
end
