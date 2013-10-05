function deriveBasisMoments(i, j)
  s = struct;
  s.y = sym('y');
  s.i = sym('i');
  s.j = sym('j');

  if nargin > 0
    s.i = i;
  end

  if nargin > 1
    verify(i, j);
    s.j = j;
  end

  E = deriveExpectation(s);
  R = deriveSecondRawMoment(s);
  V = deriveVariance(s);

  fprintf('Expectation:    %s\n', char(E));
  fprintf('2nd raw moment: %s\n', char(R));
  fprintf('Variance:       %s\n', char(V));
end
