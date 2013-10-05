function assessBasisMoments(i, j, symbolic)
  if nargin < 3, symbolic = false; end

  fprintf('Level: %d\n', i);
  fprintf('Order: %d\n', j);

  J = index(i);
  if ~any(J == j)
    fprintf('The order should be one of the following:\n')
    disp(J);
    return
  end

  Ea = expectation(i, j);
  Va = variance(i, j);

  fprintf('Analytical:\n');
  fprintf('  Expectation: %10.8f\n', Ea);
  fprintf('  Variance:    %10.8f\n', Va);

  En = integral(@(x) Test.ASGC.computeBasis(x, i, j), 0, 1);
  Vn = integral(@(x) Test.ASGC.computeBasis(x, i, j).^2, 0, 1) - En^2;

  fprintf('Numerical:\n');
  fprintf('  Expectation: %10.8f\n', En);
  fprintf('  Variance:    %10.8f\n', Vn);

  if ~symbolic, return; end

  i = sym('i');
  j = sym('j');
  y = sym('y');

  mi = 2^(i - 1) + 1;
  yij = (j - 1) / (mi - 1);

  Es = int(1 + (mi - 1) * (y - yij), y, yij - 1 / (mi - 1), yij) + ...
    int(1 - (mi - 1) * (y - yij), yij, yij + 1 / (mi - 1));

  Vs = int((1 + (mi - 1) * (y - yij))^2, y, yij - 1 / (mi - 1), yij) + ...
    int((1 - (mi - 1) * (y - yij))^2, yij, yij + 1 / (mi - 1)) - Es^2;

  fprintf('Symbolic (for i > 2):\n');
  fprintf('  Expectation: %s\n', char(Es));
  fprintf('  Variance:    %s\n', char(Vs));
end

function result = expectation(i, j)
  switch i
  case 1
    result = 1;
  case 2
    result = 1 / 4;
  otherwise
    result = 2^(1 - i);
  end
end

function result = variance(i, j)
  switch i
  case 1
    result = 0;
  case 2
    result = 5 / 48;
  otherwise
    result = 2^(2 - i) / 3 - 2^(2 - 2 * i);
  end
end

function I = index(i)
  switch i
  case 1
    I = 1;
  case 2
    I = [ 1 3 ];
  case 3
    I = [ 2 4 ];
  otherwise
    J = index(i - 1);
    I = [];
    for j = J
      I = [ I,  2 * j - 2, 2 * j ];
    end
  end
end
