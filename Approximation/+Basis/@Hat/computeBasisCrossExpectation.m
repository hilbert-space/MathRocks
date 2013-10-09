function result = computeBasisCrossExpectation(this, I1, J1, I2, J2)
  [ II, K ] = sort([ I1(:), I2(:) ], 2);
  JJ = [ J1(:), J2(:) ];
  for i = 1:size(K, 1)
    JJ(i, :) = JJ(i, K(i, :));
  end

  [ IJ, ~, K ] = unique([ II, JJ ], 'rows');
  count = size(IJ, 1);

  [ IJ, ~, H ] = unique( ...
    [ IJ(:, 1), IJ(:, 3); IJ(:, 2), IJ(:, 4) ], 'rows');
  [ Yij, Mi, ~, L, R ] = this.computeNodes(IJ(:, 1), IJ(:, 2));

  result = zeros(count, 1);
  for k = 1:count
    n1 = H(k);
    n2 = H(k + count);

    i1 = IJ(n1, 1);
    i2 = IJ(n2, 1);

    j1 = IJ(n1, 2);
    j2 = IJ(n2, 2);

    if i1 == i2
      %
      % Second raw moments (see deriveSecondRawMoment).
      %
      % int_0^1 (1 - (mi1 - 1) * |y - yij1|)^2 dy
      %
      if i1 == 1
        result(k) = 1;
      elseif i1 == 2
        result(k) = 1 / 6;
      else
        result(k) = 2.^(2 - i1) / 3;
      end
      continue;
    end

    %
    % At this point,
    %
    assert(i1 < i2 && L(n1) <= L(n2) && R(n2) <= R(n1));

    if i1 == 1
      if i2 == 2
        %
        % l = 0 or 0.5
        % r = 0.5 or 1
        %
        % (r - l) - (mi2 - 1) * int_l^r |y - y2| dy
        %
        result(k) = 1 / 4;
      else
        %
        % l = yij2 - 1 / (mi2 - 1)
        % r = yij2 + 1 / (mi2 - 1)
        %
        % (r - l) - (mi2 - 1) * int_l^r |y - y2| dy
        %
        result(k) = 2^(1 - i2);
      end
      continue;
    end

    %
    % At this point,
    %
    assert(i2 > 2);

    %
    % l = yij2 - 1 / (mi2 - 1)
    % r = yij2 + 1 / (mi2 - 1)
    %
    result(k) = ...
      ... (r - l)
      + 2^(2 - i2) ...
      ... (mi1 - 1) * int_l^r |y - yij1| dy
      - abs((j2 - 1) * 2^(i1 - 2 * i2 + 2) - (j1 - 1) * 2^(2 - i2)) ...
      ... (mi2 - 1) * int_l^r |y - yij2| dy
      - 2^(1 - i2) ...
      ... (mi1 - 1) * (mi2 - 1) int_l^r |y - yij1| * |y - yij2| dy
      + abs((j2 - 1) * 2^(i1 - 2 * i2 + 1) - (j1 - 1) * 2^(1 - i2));
  end

  result = prod(reshape(result(K), size(I1)), 2);
end
