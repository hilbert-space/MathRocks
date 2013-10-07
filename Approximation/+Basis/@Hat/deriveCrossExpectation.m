function result = deriveCrossExpectation(this, i1, j1, i2, j2)
  y = sym('y');

  [ yij1, mi1, ~, l1, r1 ] = this.computeNodes(i1, j1);
  [ yij2, mi2, ~, l2, r2 ] = this.computeNodes(i2, j2);

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
