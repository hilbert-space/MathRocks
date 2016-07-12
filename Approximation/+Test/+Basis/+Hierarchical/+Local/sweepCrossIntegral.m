function sweepCrossIntegral(varargin)
  options = Options(varargin{:});

  basis = Basis(options);
  assess = options.get('assess', true);

  levels = zeros(1, 0);
  orders = zeros(1, 0);

  for i = options.levels
    J = basis.computeLevelOrders(i);
    count = length(J);
    levels = [levels, i * ones(1, count)];
    orders = [orders, sort(J)];
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
        one = double(call(basis, 'deriveCrossIntegral', ...
          'i1', levels(k), 'j1', orders(k), ...
          'i2', levels(l), 'j2', orders(l)));
        two = call(basis, 'estimateCrossIntegral', ...
          'i1', levels(k), 'j1', orders(k), ...
          'i2', levels(l), 'j2', orders(l));
        fprintf('%10.4f', one - two);
      else
        fprintf('%10s', char(call(basis, 'deriveCrossIntegral', ...
          'i1', levels(k), 'j1', orders(k), ...
          'i2', levels(l), 'j2', orders(l))));
      end
    end
    fprintf('\n');
  end
end

function name = name(i, j)
  name = sprintf('%2s/%2s', String(i), String(j));
end
