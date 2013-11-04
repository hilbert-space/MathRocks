function countQuadratureNodes(varargin)
  setup;

  quadratureNames = { 'GaussHermite' };
  polynomialOrder = [ 1 2 3 4 5 ];
  processorCountSet  = [ 2 4 8 16 32 ];

  dimensionCountSet = zeros(length(processorCountSet), 1);

  for i = 1:length(processorCountSet)
    options = Configure.systemSimulation(varargin{:}, ...
      'processorCount', processorCountSet(i));
    options = Configure.processVariation(options);
    process = ProcessVariation(options.processOptions);
    dimensionCountSet(i) = sum(process.dimensions);
  end

  for k = 1:(2 * length(quadratureNames))
    name = quadratureNames{ceil(k / 2)};
    sparse = mod(k, 2) == 1;

    if sparse
      fprintf('Sparse %s grid\n', name);
      method = 'sparse';
    else
      fprintf('Full-tensor-product %s gird\n', name);
      method = 'tensor';
    end

    fprintf('%10s%10s', 'PC order', 'QD order');
    for i = 1:length(processorCountSet)
      fprintf('%15s', sprintf('%d / %d', ...
        processorCountSet(i), dimensionCountSet(i)));
    end
    fprintf('\n');

    for i = 1:length(polynomialOrder)
      level = polynomialOrder(i) + 1 - 1;

      fprintf('%10d%10d', polynomialOrder(i), level);

      for j = 1:length(processorCountSet)
        if sparse
          quadrature = Quadrature.(name)( ...
            'dimensionCount', dimensionCountSet(j), ...
            'level', level, 'method', method);
          fprintf('%15d', quadrature.nodeCount);
        else
          quadrature = Quadrature.(name)( ...
            'dimensionCount', 1, ...
            'level', level, 'method', method);
          fprintf('%15d', quadrature.nodeCount^dimensionCountSet(j));
        end
      end
      fprintf('\n');
    end
    fprintf('\n');
  end
end
