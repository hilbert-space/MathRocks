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
    i = H(k);
    j = H(k + count);

    if i == j
      if i == 1
        result(k) = 1;
      elseif i == 2
        result(k) = 1 / 6;
      else
        result(k) = 2.^(2 - i) / 3;
      end
      continue;
    end

    yij1 = Yij(i);
    yij2 = Yij(j);

    mi1 = Mi(i);
    mi2 = Mi(j);

    l = max(L(i), L(j));
    r = min(R(i), R(j));

    assert(l < r);

    if i == 1
      result(k) = (r - l) ...
        - (mi2 - 1) * intAbsOne(yij2, l, r);
    elseif j == 1
      result(k) = (r - l) ...
        - (mi1 - 1) * intAbsOne(yij1, l, r);
    else
      result(k) = (r - l) ...
        - (mi1 - 1) * intAbsOne(yij1, l, r) ...
        - (mi2 - 1) * intAbsOne(yij2, l, r) ...
        + (mi1 - 1) * (mi2 - 1) * intAbsTwo(yij1, yij2, l, r);
    end
  end

  result = prod(reshape(result(K), size(I1)), 2);
end

function result = intOne(yij, l, r)
  %
  % int_l^r (y - yij) dy
  %
  result = (r^2 - l^2) / 2 - (r - l) * yij;
end

function result = intTwo(yij1, yij2, l, r)
  %
  % int_l^r (y - yij1) * (y - yij2) dy
  %
  result = (r^3 - l^3) / 3 ...
    - (r^2 - l^2) * (yij1 + yij2) / 2 ...
    + (r - l) * yij1 * yij2;
end

function result = intAbsOne(yij, l, r)
  %
  % int_l^r |y - yij| dy
  %
  if yij <= l
    result = intOne(yij, l, r);
  elseif yij >= r
    result = - intOne(yij, l, r);
  else
    result = - intOne(yij, l, yij) + intOne(yij, yij, r);
  end
end

function result = intAbsTwo(yij1, yij2, l, r)
  %
  % int_l^r |y - yij1| * |y - yij2| dy
  %
  if yij1 <= l
    if yij2 <= l
      result = ...
        + intTwo(yij1, yij2, l, r);
    elseif yij2 >= r
      result = ...
        - intTwo(yij1, yij2, l, r);
    else
      result = ...
        - intTwo(yij1, yij2, l, yij2) ...
        + intTwo(yij1, yij2, yij2, r);
    end
  elseif yij1 >= r
    if yij2 <= l
      result = ...
        - intTwo(yij1, yij2, l, r);
    elseif yij2 >= r
      result = ...
        + intTwo(yij1, yij2, l, r);
    else
      result = ...
        + intTwo(yij1, yij2, l, yij2) ...
        - intTwo(yij1, yij2, yij2, r);
    end
  else
    if yij2 <= l
      result = ...
        - intTwo(yij1, yij2, l, yij1) ...
        + intTwo(yij1, yij2, yij1, r);
    elseif yij2 >= r
      result = ...
        + intTwo(yij1, yij2, l, yij1) ...
        - intTwo(yij1, yij2, yij1, r);
    else
      a = min(yij1, yij2);
      b = max(yij1, yij2);
      result = ...
        + intTwo(yij1, yij2, l, a) ...
        - intTwo(yij1, yij2, a, b) ...
        + intTwo(yij1, yij2, b, r);
    end
  end
end
