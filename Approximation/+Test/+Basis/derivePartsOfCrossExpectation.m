function derivePartsOfCrossExpectation
  syms i1 i2 j1 j2

  [ yij, mi, ~, l, r ] = configure(2, 1);
  disp('1. i1 = 1, i2 = 2: (r - l) - (mi2 - 1) * int_l^r |y - y2| dy');
  show((r - l) - (mi - 1) * intOne(yij, l, r));

  [ yij, mi, ~, l, r ] = configure(i2, j2);
  disp('2. i1 = 1, i2 ~= 2: (r - l) - (mi2 - 1) * int_l^r |y - y2| dy');
  show((r - l) - (mi - 1) * (-intOne(yij, l, yij) + intOne(yij, yij, r)));

  [ ~, ~, ~, l, r ] = configure(i2, j2);
  disp('3. r - l');
  show(r - l);

  [ yij1, mi1 ] = configure(i1, j1);
  [ ~, ~, ~, l, r ] = configure(i2, j2);
  disp('4. i1 ~= 1, i2 > 2: (mi1 - 1) * int_l^r |y - yij1| dy');
  show((mi1 - 1) * intOne(yij1, l, r));

  [ yij2, mi2, ~, l, r ] = configure(i2, j2);
  disp('5. i1 ~= 1, i2 > 2: (mi1 - 1) * int_l^r |y - yij1| dy');
  show((mi2 - 1) * (-intOne(yij2, l, yij2) + intOne(yij2, yij2, r)));

  [ yij1, mi1 ] = configure(i1, j1);
  [ yij2, mi2, ~, l, r ] = configure(i2, j2);
  disp('6. i1 ~= 1, i2 > 2: (mi1 - 1) * (mi2 - 1) int_l^r |y - yij1| * |y - yij2| dy');
  show((mi1 - 1) * (mi2 - 1) * (-intTwo(yij1, yij2, l, yij2) + intTwo(yij1, yij2, yij2, r)));
end

function [ yij, mi, li, l, r ] = configure(i, j)
  if i == 1
    mi = 1;
    li = 1;
    yij = 0.5;
  else
    mi = 2^(i - 1) + 1;
    li = 1 / (mi - 1);
    yij = (j - 1)  * li;
  end

  l = yij - li;
  r = yij + li;

  if isa(l, 'double')
    l = max(0, l);
    r = min(1, r);
  end
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
  result = (r - l) * ((r^2 + r * l + l^2) / 3 - ...
    (r + l) * (yij1 + yij2) / 2 + yij1 * yij2);
end

function show(some)
  if isa(some, 'sym')
    disp(simplify(some));
  else
    disp(some);
  end
end
