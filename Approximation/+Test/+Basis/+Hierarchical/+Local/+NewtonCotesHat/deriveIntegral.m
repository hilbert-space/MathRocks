function result = deriveIntegral(basis, options)
  i = options.get('i', sym('i'));
  j = options.get('j', sym('j'));

  validate(basis, i, j);

  switch i
  case 1
    result = sym(1);
  case 2
    y = sym('y');
    result = int(1 - 2 * y, y, 0, 0.5);
  otherwise
    y = sym('y');
    mi = 2^(i - 1) + 1;
    yij = (j - 1) / (mi - 1);
    delta = 1 / (mi - 1);
    result = ...
      int(1 + (mi - 1) * (y - yij), y, yij - delta, yij) + ...
      int(1 - (mi - 1) * (y - yij), y, yij, yij + delta);
  end
end
