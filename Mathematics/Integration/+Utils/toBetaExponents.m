function [ alpha, beta ] = toBetaExponents(alpha, beta)
  %
  % The weight of the Jacobi polynomials on the interval [-1, 1]:
  %
  % (1 - x)^alpha * (1 + x)^beta = (x - (-1))^beta * (1 - x)^alpha.
  %
  % The weight of beta distributions on the interval [a, b]:
  %
  % B * (x - a)^(alpha - 1) * (b - x)^(beta - 1).
  %
  [ alpha, beta ] = deal(beta + 1, alpha + 1);
end
