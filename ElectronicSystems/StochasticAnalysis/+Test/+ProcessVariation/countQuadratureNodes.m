function countQuadratureNodes(varargin)
  setup;

  polynomialOrders = [ 1 2 3 4 5 ];
  processorCounts  = [ 2 4 8 16 32 ];
  dimensionCounts = zeros(length(processorCounts), 1);

  for i = 1:length(processorCounts)
    options = Configure.systemSimulation( ...
      varargin{:}, 'processorCount', processorCounts(i));
    options = Configure.deterministicAnalysis(options);
    options = Configure.stochasticAnalysis(options);
    process = ProcessVariation(options.processOptions);
    dimensionCounts(i) = sum(process.dimensions);
  end

  count('GaussHermite', 'sparse', ...
    polynomialOrders, processorCounts, dimensionCounts);
  count('GaussHermite', 'tensor', ...
    polynomialOrders, processorCounts, dimensionCounts);
end

function count(name, method, polynomialOrders, processorCounts, dimensionCounts)
  switch method
  case 'tensor'
    fprintf('Full-tensor-product %s grid\n', name);
  case 'sparse'
    fprintf('Sparse %s grid\n', name);
  otherwise
    assert(false);
  end

  fprintf('%10s%10s', 'PC order', 'QD order');
  for i = 1:length(processorCounts)
    fprintf('%15s', sprintf('%d / %d', ...
      processorCounts(i), dimensionCounts(i)));
  end
  fprintf('\n');

  for i = 1:length(polynomialOrders)
    level = polynomialOrders(i) + 1 - 1; % slow-linear growth

    fprintf('%10d%10d', polynomialOrders(i), level);

    for j = 1:length(processorCounts)
      switch method
      case 'tensor'
        quadrature = Quadrature.(name)( ...
          'dimensionCount', 1, 'level', level, ...
          'method', method, 'growth', 'slow-linear');
        fprintf('%15d', quadrature.nodeCount^dimensionCounts(j));
      case 'sparse'
        quadrature = Quadrature.(name)( ...
          'dimensionCount', dimensionCounts(j), 'level', level, ...
          'method', method, 'growth', 'slow-linear');
        fprintf('%15d', quadrature.nodeCount);
      end
    end
    fprintf('\n');
  end
end
