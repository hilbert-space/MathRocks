function [ nodes, weights ] = GaussHermite(order)
  [ nodes, weights ] = Quadrature.Rules.GaussHermitePhysicist(order);

  %
  % The computed nodes and weights can be used to evaluate integrals with
  % the weight function e^(-y^2). However, we need the standard Gaussian
  % weight, i.e., (1 / sqrt(2 * pi)) e^(-x^2 / 2); therefore, we apply
  % one transofrmation to the nodes:
  %
  nodes   = sqrt(2) * nodes;
  %
  % and one to the weights:
  %
  % weights = sqrt(2) * weights / sqrt(2 * pi);
  %
  % which simplified to:
  %
  weights = weights / sqrt(pi);
end
