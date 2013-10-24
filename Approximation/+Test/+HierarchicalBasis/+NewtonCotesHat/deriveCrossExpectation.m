function result = deriveCrossExpectation(basis, i1, j1, i2, j2)
  y = sym('y');

  [ yij1, li1, mi1 ] = basis.computeNodes(i1, j1);
  [ yij2, li2, mi2 ] = basis.computeNodes(i2, j2);

  l1 = max(0, yij1 - li1);
  r1 = min(1, yij1 + li1);

  l2 = max(0, yij2 - li2);
  r2 = min(1, yij2 + li2);

  l = max(l1, l2);
  r = min(r1, r2);

  if l >= r
    result = sym(0);
  else
    result = int( ...
      (1 - (mi1 - 1) * abs(y - yij1)) * ...
      (1 - (mi2 - 1) * abs(y - yij2)), y, l, r);
  end
end
