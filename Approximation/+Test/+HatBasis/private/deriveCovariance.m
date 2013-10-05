function result = deriveCovariance(s1, s2)
  y = s1.y;
  assert(logical(y == s2.y));

  [ mi1, yij1, l1, r1 ] = configure(s1);
  [ mi2, yij2, l2, r2 ] = configure(s2);

  l = max(l1, l2);
  r = min(r1, r2);

  c1 = min(r, max(l, yij1));
  c2 = min(r, max(l, yij1));

  result1 = ...
    - int(y - yij1, y, l, c1) ...
    + int(y - yij1, y, c1, r);

  c1 = min(r, max(l, yij2));
  c2 = min(r, max(l, yij2));

  result2 = ...
    - int(y - yij2, y, l, c1) ...
    + int(y - yij2, y, c1, r);

  c1 = min(r, max(l, min(yij1, yij2)));
  c2 = max(l, min(r, max(yij1, yij2)));

  result3 = ...
    + int((y - yij1) * (y - yij2), y,  l, c1) ...
    - int((y - yij1) * (y - yij2), y, c1, c2) ...
    + int((y - yij1) * (y - yij2), y, c2,  r);

  result = (max(r, l) - l) + ...
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
