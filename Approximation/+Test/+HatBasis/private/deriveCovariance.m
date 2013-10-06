function result = deriveCovariance(s1, s2)
  y = s1.y;
  assert(logical(y == s2.y));

  [ mi1, yij1, l1, r1 ] = configure(s1);
  [ mi2, yij2, l2, r2 ] = configure(s2);

  i1 = int(y - yij1, y);
  i2 = int(y - yij2, y);
  i3 = int((y - yij1) * (y - yij2), y);

  max = @(a, b) feval(symengine, 'max', a, b);
  min = @(a, b) feval(symengine, 'min', a, b);

  l = max(l1, l2);
  r = max(min(r1, r2), l);

  c1 = min(r, max(l, yij1));

  result1 = ...
    - (subs(i1, y, c1) - subs(i1, y,  l)) ...
    + (subs(i1, y,  r) - subs(i1, y, c1));

  c2 = min(r, max(l, yij2));

  result2 = ...
    - (subs(i2, y, c2) - subs(i2, y,  l)) ...
    + (subs(i2, y,  r) - subs(i2, y, c2));

  c3 = min(c1, c2);
  c4 = max(c1, c2);

  result3 = ...
    + (subs(i3, y, c3) - subs(i3, y,  l)) ...
    - (subs(i3, y, c4) - subs(i3, y, c3)) ...
    + (subs(i3, y,  r) - subs(i3, y, c4));

  result = (r - l) + ...
    - (mi1 - 1) * result1 ...
    - (mi2 - 1) * result2 ...
    + (mi1 - 1) * (mi2 - 1) * result3 ...
    - deriveExpectation(s1) * deriveExpectation(s2);
end

function [ mi, yij, l, r ] = configure(s)
  switch s.i
  case 1
    mi = 1;
    yij = 0.5;
    l = 0;
    r = 1;
  case 2
    mi = 3;
    yij = (s.j - 1) / (mi - 1);
    l = max(0, yij - 0.5);
    r = min(1, yij + 0.5);
  otherwise
    mi = 2^(s.i - 1) + 1;
    yij = (s.j - 1) / (mi - 1);
    l = yij - 1 / (mi - 1);
    r = yij + 1 / (mi - 1);
  end
end
