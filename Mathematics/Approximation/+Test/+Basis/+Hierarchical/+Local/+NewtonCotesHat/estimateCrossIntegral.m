function result = estimateCrossIntegral(basis, options)
  i1 = options.i1;
  j1 = options.j1;
  i2 = options.i2;
  j2 = options.j2;

  validate(basis, i1, j1);
  validate(basis, i2, j2);

  result = integral(@(Y) ...
    basis.evaluate(Y(:), i1, j1, ones(size(Y)).').' .* ...
    basis.evaluate(Y(:), i2, j2, ones(size(Y)).').', ...
    basis.support(1), basis.support(2));
end
