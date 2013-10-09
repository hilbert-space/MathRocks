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

    if i1 == i2
      if i1 == 1
        result(k) = 1;
      elseif i1 == 2
        result(k) = 1 / 6;
      else
        result(k) = 2.^(2 - i1) / 3;
      end
      continue;
    end

    yij1 = Yij(n1);
    yij2 = Yij(n2);

    mi1 = Mi(n1);
    mi2 = Mi(n2);

    l = L(n2);
    r = R(n2);

    %
    % At this point,
    %
    assert(i1 < i2 && L(n1) <= l && r <= R(n1));

    if i1 == 1
      if i2 == 2
        result(k) = 1 / 4;
      else
        result(k) = 2^(1 - i2);
      end
      continue;
    end

    %
    % At this point,
    %
    assert(i2 > 2);

    result(k) = (r - l) ...
      - (mi1 - 1) * intAbsOne(yij1, l, r) ...
      - (mi2 - 1) * intAbsOne(yij2, l, r) ...
      + (mi1 - 1) * (mi2 - 1) * intAbsTwo(yij1, yij2, l, r);
  end

  result = prod(reshape(result(K), size(I1)), 2);
end

function result = intTwo(yij1, yij2, l, r)
  %
  % int_l^r (y - yij1) * (y - yij2) dy
  %
  result = (r - l) * ((r^2 + r * l + l^2) / 3 - ...
    (r + l) * (yij1 + yij2) / 2 + yij1 * yij2);
end

function result = intAbsOne(yij, l, r)
  %
  % int_l^r |y - yij| dy
  %
  if yij <= l
    result = (r - l) * ((l - yij) + (r - yij)) / 2;
  elseif yij >= r
    result = (r - l) * ((yij - l) + (yij - r)) / 2;
  else
    result = ((l - yij)^2 + (r - yij)^2) / 2;
  end
  assert(result >= 0);
end

function result = intAbsTwo(yij1, yij2, l, r)
  %
  % int_l^r |y - yij1| * |y - yij2| dy
  %
  % NOTE: Since (a) there is an overlap between the supports
  % of the two basis functions, (c) a higher-level support is
  % composed of an even number of low-level supports, (b) i1 < i2,
  % the support of the second function is always inside of the
  % support of the first function, and yij1 is always outside or
  % on the border of the integration range.
  %
  assert(l < yij2 && yij2 < r);
  if yij1 < yij2
    assert(yij1 <= l);
    result = ...
      - intTwo(yij1, yij2, l, yij2) ...
      + intTwo(yij1, yij2, yij2, r);
  else
    assert(yij1 >= r);
    result = ...
      + intTwo(yij1, yij2, l, yij2) ...
      - intTwo(yij1, yij2, yij2, r);
  end
  if result < 0
    fprintf('absTwo: %g < 0 \n', result);
  end
end
