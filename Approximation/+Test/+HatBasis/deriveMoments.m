function deriveMoments(i, j)
  s = struct('y', sym('y'), 'i', sym('i'), 'j', sym('j'));

  if nargin > 0
    s.i = i;
  end

  if nargin > 1
    validate(i, j);
    s.j = j;
  end

  E = deriveExpectation(s);
  R = deriveSecondRawMoment(s);
  V = deriveVariance(s);

  fprintf('Expectation:       %s\n', char(E));
  fprintf('Second raw moment: %s\n', char(R));
  fprintf('Variance:          %s\n', char(V));
end
