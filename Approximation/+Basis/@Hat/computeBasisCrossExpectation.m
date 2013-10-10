function result = computeBasisCrossExpectation(~, I1, J1, I2, J2)
  [ II, K ] = sort([ I1(:), I2(:) ], 2);
  JJ = [ J1(:), J2(:) ];
  K = K(:, 1) == 2;
  JJ(K, :) = fliplr(JJ(K, :));

  [ IJ, ~, K ] = unique([ II, JJ ], 'rows');
  count = size(IJ, 1);

  result = zeros(count, 1);

  %
  % Second raw moments (see deriveSecondRawMoment).
  %
  % int_0^1 (1 - (mi1 - 1) * |y - yij1|)^2 dy
  %
  L = find(IJ(:, 1) == IJ(:, 2));
  result(L) = 2.^(2 - IJ(L, 1)) / 3;
  result(L(IJ(L, 1) == 1)) = 1;
  result(L(IJ(L, 1) == 2)) = 1 / 6;

  L = setdiff(1:count, L);
  M = L(IJ(L, 1) == 1);
  %
  % l = yij2 - 1 / (mi2 - 1)
  % r = yij2 + 1 / (mi2 - 1)
  %
  % (r - l) - (mi2 - 1) * int_l^r |y - y2| dy
  %
  result(M) = 2.^(1 - IJ(M, 2));
  %
  % l = 0 or 0.5
  % r = 0.5 or 1
  %
  % (r - l) - (mi2 - 1) * int_l^r |y - y2| dy
  %
  result(M(IJ(M, 2) == 2)) = 1 / 4;

  L = setdiff(L, M);

  %
  % l = yij2 - 1 / (mi2 - 1)
  % r = yij2 + 1 / (mi2 - 1)
  %
  result(L) = ...
    ... (r - l)
    + 2.^(2 - IJ(L, 2)) ...
    ... (mi1 - 1) * int_l^r |y - yij1| dy
    - abs((IJ(L, 4) - 1) .* 2.^(IJ(L, 1) - 2 * IJ(L, 2) + 2) - (IJ(L, 3) - 1) .* 2.^(2 - IJ(L, 2))) ...
    ... (mi2 - 1) * int_l^r |y - yiIJ(L, 4)| dy
    - 2.^(1 - IJ(L, 2)) ...
    ... (mi1 - 1) * (mi2 - 1) int_l^r |y - yij1| * |y - yiIJ(L, 4)| dy
    + abs((IJ(L, 4) - 1) .* 2.^(IJ(L, 1) - 2 * IJ(L, 2) + 1) - (IJ(L, 3) - 1) .* 2.^(1 - IJ(L, 2)));

  result = prod(reshape(result(K), size(I1)), 2);
end
