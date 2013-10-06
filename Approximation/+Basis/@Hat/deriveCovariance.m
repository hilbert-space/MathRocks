function result = deriveCovariance(this, i1, j1, i2, j2)
  y = sym('y');

  [ mi1, yij1, l1, r1 ] = configure(i1, j1);
  [ mi2, yij2, l2, r2 ] = configure(i2, j2);

  l = max(l1, l2);
  r = min(r1, r2);

  e1 = this.deriveExpectation(i1, j1);
  e2 = this.deriveExpectation(i2, j2);

  if l >= r
    result = - e1 * e2;
  else
    result = int( ...
      (1 - (mi1 - 1) * abs(y - yij1)) * ...
      (1 - (mi2 - 1) * abs(y - yij2)), y, l, r) - e1 * e2;
  end
end

function [ mi, yij, l, r ] = configure(i, j)
  switch i
  case 1
    mi = 1;
    yij = 0.5;
    l = 0;
    r = 1;
  case 2
    mi = 3;
    yij = (j - 1) / (mi - 1);
    l = max(0, yij - 0.5);
    r = min(1, yij + 0.5);
  otherwise
    mi = 2^(i - 1) + 1;
    yij = (j - 1) / (mi - 1);
    l = yij - 1 / (mi - 1);
    r = yij + 1 / (mi - 1);
  end
end
