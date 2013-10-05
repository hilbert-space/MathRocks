function deriveCovariance(i1, j1, i2, j2)
  s1 = struct('y', sym('y'), 'i', sym('i1'), 'j', sym('j1'));
  s2 = struct('y', sym('y'), 'i', sym('i2'), 'j', sym('j2'));

  if exist('i1', 'var')
    s1.i = i1;
  end

  if exist('j1', 'var')
    validate(i1, j1);
    s1.j = j1;
  end

  if exist('i2', 'var')
    s2.i = i2;
  end

  if exist('j2', 'var')
    validate(i2, j2);
    s2.j = j2;
  end

  C = deriveCovariance(s1, s2);
  fprintf('Covariance: %s\n', char(C));
end
