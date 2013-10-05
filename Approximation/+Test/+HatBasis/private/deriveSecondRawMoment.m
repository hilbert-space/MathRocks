function result = deriveSecondRawMoment(s)
  switch s.i
  case 1
    result = sym(1);
  case 2
    y = sym('y');
    result = int((1 - 2 * y)^2, y, 0, 0.5);
  otherwise
    mi = 2^(s.i - 1) + 1;
    yij = (s.j - 1) / (mi - 1);
    delta = 1 / (mi - 1);
    result = ...
      int((1 + (mi - 1) * (s.y - yij))^2, s.y, yij - delta, yij) + ...
      int((1 - (mi - 1) * (s.y - yij))^2, s.y, yij, yij + delta);
  end
end
