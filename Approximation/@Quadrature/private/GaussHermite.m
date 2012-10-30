function [ nodes, weights ] = GaussHermite(order)
  [ nodes, weights ] = GaussHermitePhysicist(order);
  %
  % The computed nodes and weights can be used to evaluate integrals with
  % the weight function
  %
  % exp(- y^2).
  %
  % However, we need the standard Gaussian weight, i.e.,
  %
  %       1            x^2
  % ------------ exp(- ---).
  % sqrt(2 * pi)        2
  %
  % Therefore, we transform the nodes as
  %
  nodes = sqrt(2) * nodes;
  %
  % and the weights as
  %
  % weights = sqrt(2) * weights / sqrt(2 * pi);
  %
  % which is simplified to:
  %
  weights = weights / sqrt(pi);
end
