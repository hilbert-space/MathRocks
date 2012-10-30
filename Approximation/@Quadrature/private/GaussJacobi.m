function [ nodes, weights ] = GaussJacobi(order, alpha, beta_, a, b)
  [ nodes, weights ] = jacobi_compute(order, alpha, beta_);
  %
  % The computed nodes and weights can be used to evaluate integrals with
  % the weight function equal to
  %
  % (1 - y)^alpha * (1 + y)^beta
  %
  % where the integration goes from -1 to 1. However, we need the
  % four-parameter beta weight, i.e.,
  %
  %            (x - a)^alpha * (b - x)^beta
  % ------------------------------------------------------
  % (b - a)^(alpha + beta + 1) * Beta(alpha + 1, beta + 1)
  %
  % where the integration is from a to b.
  %
  % NOTE: There is a difference in the exponents between the Jacobi
  % polynomials (J) and the standard beta distribution (B); to be specific,
  % we have alpha(J) = alpha(B) - 1, beta(J) = beta(B) - 1.
  %
  % All in all,
  %
  nodes = ((nodes + 1) / 2) * (b - a) + a;
  weights = weights / ((b - a)^(alpha + beta_ + 1) * beta(alpha + 1, beta_ + 1));
end
