function sweepCrossExpectation(I, assess)
  if nargin < 2, assess = false; end

  basis = Basis.Hat;

  levels = zeros(0, 1);
  orders = zeros(0, 1);

  for i = I
    J = basis.computeLevelOrders(i);
    count = length(J);
    levels = [ levels; i * ones(count, 1) ];
    orders = [ orders; sort(J) ];
  end

  count = length(levels);

  fprintf('%10s', name('i', 'j'));
  for k = 1:count
    fprintf('%10s', name(levels(k), orders(k)));
  end
  fprintf('\n');

  for k = 1:count
    fprintf('%10s', name(levels(k), orders(k)));
    for l = 1:count
      if l > k
        fprintf('%10s', '');
      elseif assess
        one = double(basis.deriveCrossExpectation( ...
          levels(k), orders(k), levels(l), orders(l)));
        two = basis.estimateCrossExpectation( ...
          levels(k), orders(k), levels(l), orders(l));
        fprintf('%10.4f', one - two);
      else
        fprintf('%10s', char(basis.deriveCrossExpectation( ...
          levels(k), orders(k), levels(l), orders(l))));
      end
    end
    fprintf('\n');
  end
end

function name = name(i, j)
  name = sprintf('%2s/%2s', String(i), String(j));
end
