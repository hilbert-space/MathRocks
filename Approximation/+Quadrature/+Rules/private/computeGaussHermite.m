function [ nodes, weights ] = PhysicistGaussHermite(order)
  assert(order > 0);

  %
  % Reference:
  %
  % [1] Walter G., Orthogonal Polynomials Computation and Approximation,
  % Oxford Press, 2004.
  %
  % The three-terms recurrence relation for the Hermite polynomials
  % with the weight function e^(-x^2) has the following coefficients
  % (see page 13 in [1]):
  %
  % alpha_k = 0, beta_0 = sqrt(pi), beta_k = k / 2.
  %
  if order == 1
    alpha = 0;
    beta = sqrt(pi);
    J = alpha;
  else
    alpha = zeros(order, 1);
    beta = [ sqrt(pi); 0.5 * (1:(order - 1)).' ];
    J = full(spdiags( ...
      [ circshift(sqrt(beta), -1) alpha sqrt(beta) ], ...
      [ -1, 0, 1 ], order, order));
  end

  [ V, L ] = eig(J);

  %
  % The eigenvectors, the columns of V, are orthonormal, i.e.,
  % norm(V(:, i)) = 1.
  %

  nodes = diag(L);
  assert(issorted(nodes));

  %
  % The weights are the first components of the eigenvalues squared
  % and multiplied by beta_0 (see page 153 in [1]).
  %
  weights = beta(1) * V(1, :).'.^2;
end
