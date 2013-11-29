function result = estimateIntegral(basis, options)
  if ~options.has('i') || ~options.has('j')
    result = NaN;
    return;
  end

  i = options.i;
  j = options.j;

  validate(basis, i, j);

  result = integral(@(Y) ...
    basis.evaluate(Y(:), i, j, ones(size(Y)).').', ...
    basis.support(1), basis.support(2));
end
