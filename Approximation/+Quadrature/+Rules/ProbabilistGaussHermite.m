function [ nodes, weights ] = ProbabilistGaussHermite(order)
  [ nodes, weights ] = Quadrature.Rules.PhysicistGaussHermite(order);

  %
  % Now, the nodes and weights can be used to compute integrals with
  % the weight function e^(-y^2). However, we need e^(-x^2 / 2);
  % therefore, we perform the following change of variables:
  %
  nodes   = sqrt(2) * nodes;
  weights = sqrt(2) * weights;
end
