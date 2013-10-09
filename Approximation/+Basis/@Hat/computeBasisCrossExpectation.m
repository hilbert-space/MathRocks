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
    i1 = H(k);
    i2 = H(k + count);

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

    yij1 = Yij(i1);
    yij2 = Yij(i2);

    mi1 = Mi(i1);
    mi2 = Mi(i2);

    l1 = L(i1);
    l2 = L(i2);

    r1 = R(i1);
    r2 = R(i2);

    %
    % At this point,
    %
    assert(i1 < i2 && max(l1, l2) < min(r1, r2));

    if i1 == 1
      result(k) = (r2 - l2) ...
        - (mi2 - 1) * intAbsOne(yij2, l2, r2);
      continue;
    end

    l = max(l1, l2);
    r = min(r1, r2);

    result(k) = (r2 - l2) ...
      - (mi1 - 1) * intAbsOne(yij1, l2, r2) ...
      - (mi2 - 1) * intAbsOne(yij2, l2, r2) ...
      + (mi1 - 1) * (mi2 - 1) * intAbsTwo(yij1, yij2, l2, r2);
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
  % result = (r^3 - l^3) / 3 ...
  %   - (r^2 - l^2) * (yij1 + yij2) / 2 ...
  %   + (r - l) * yij1 * yij2;
  result = (r - l) * ((r^2 + r * l + l^2) / 3 - ...
    (r + l) * (yij1 + yij2) / 2 + yij1 * yij2);
end

function result = intAbsOne(yij, l, r)
  %
  % int_l^r |y - yij| dy
  %
  if yij <= l
    % result = intOne(yij, l, r);
    result = (r - l) * ((l - yij) + (r - yij)) / 2;
  elseif yij >= r
    % result = - intOne(yij, l, r);
    result = (r - l) * ((yij - l) + (yij - r)) / 2;
  else
    % result = - intOne(yij, l, yij) + intOne(yij, yij, r);
    result = ((l - yij)^2 + (r - yij)^2) / 2;
  end
  if result < 0
    fprintf('absOne: %g < 0 \n', result);
  end
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
