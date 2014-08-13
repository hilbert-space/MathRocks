function variance = computeVariance(this, I, J, surpluses)
  expectation = this.integrate(I);

  result1 = sum(bsxfun(@times, surpluses.^2, ...
    this.integrateSquared(I) - expectation.^2), 1);

  %
  % The summation in result2 is over all k < l; therefore,
  % we need to sum over all combinations of two elements.
  %
  P = Utils.combnk(size(I, 1), 2);
  P1 = P(:, 1);
  P2 = P(:, 2);

  %
  % First, we compute the second part of Cov(a_k, a_l).
  %
  result2 = (-1) * expectation(P1) .* expectation(P2);

  %
  % The computation of the first part, E(a_k * a_l), is only
  % relevant for those basis functions that have intersections.
  % Let us find them.
  %
  [Yij, Li] = this.computeNodes(I, J);
  L = max(0, Yij - Li);
  R = min(1, Yij + Li);
  Z = all(L(P1, :) < R(P2, :) & L(P2, :) < R(P1, :), 2);

  result2(Z) = result2(Z) + this.integrateCrossed( ...
    I(P1(Z), :), J(P1(Z), :), I(P2(Z), :), J(P2(Z), :));

  Z = find(result2 ~= 0);

  result2 = sum(bsxfun(@times, surpluses(P1(Z), :) .* surpluses(P2(Z), :), ...
    result2(Z)), 1);

  variance = result1 + 2 * result2;
end
