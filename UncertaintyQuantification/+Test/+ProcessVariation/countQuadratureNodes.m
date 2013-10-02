function countQuadratureNodes(varargin)
  setup;

  quadratureRule = { 'GaussHermite', 'GaussHermiteHW' };
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

  for k = 1:(2 * length(quadratureRule))
    ruleName = quadratureRule{ceil(k / 2)};
    sparse = mod(k, 2) == 1;

    if sparse
      fprintf('Sparse %s grid\n', ruleName);
      method = 'sparse';
    else
      fprintf('Full-tensor-product %s gird\n', ruleName);
      method = 'tensor';
    end

    fprintf('%10s%10s', 'PC order', 'QD order');
    for i = 1:length(processorCountSet)
      fprintf('%15s', sprintf('%d / %d', ...
        processorCountSet(i), dimensionCountSet(i)));
    end
    fprintf('\n');

    for i = 1:length(polynomialOrder)
      order = polynomialOrder(i) + 1;

      fprintf('%10d%10d', polynomialOrder(i), order);

      for j = 1:length(processorCountSet)
        quadrature = Quadrature('dimensionCount', dimensionCountSet(j), ...
          'order', order, 'ruleName', ruleName, 'method', method);
        fprintf('%15d', quadrature.nodeCount);
      end
      fprintf('\n');
    end
    fprintf('\n');
  end
end
