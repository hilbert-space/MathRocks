setup;

quadratureRule = { 'GaussHermite', 'GaussHermiteHW' };
polynomialOrder = [ 1 2 3 4 5 ];
processorCount  = [ 2 4 8 16 32 ];

dimensionCount = zeros(length(processorCount), 1);

for i = 1:length(processorCount)
  options = Configure.systemSimulation('processorCount', processorCount(i));
  options = Configure.processVariation(options);
  process = ProcessVariation.(options.processModel)(options.processOptions);
  dimensionCount(i) = process.dimensionCount;
end

for k = 1:(2 * length(quadratureRule))
  ruleName = quadratureRule{ceil(k / 2)};
  sparse = mod(k, 2) == 1;

  if sparse
    fprintf('Quadrature rule: %s (SG)\n', ruleName);
    method = 'sparse';
  else
    fprintf('Quadrature rule: %s (TP)\n', ruleName);
    method = 'tensor';
  end

  fprintf('%10s%10s', 'PC order', 'QD order');
  for i = 1:length(processorCount)
    fprintf('%15s', sprintf('%d / %d', processorCount(i), dimensionCount(i)));
  end
  fprintf('\n');

  for i = 1:length(polynomialOrder)
    order = polynomialOrder(i) + 1;

    fprintf('%10d%10d', polynomialOrder(i), order);

    for j = 1:length(processorCount)
      quadrature = Quadrature('dimensionCount', dimensionCount(j), ...
        'order', order, 'ruleName', ruleName, 'method', method);
      fprintf('%15d', quadrature.nodeCount);
    end
    fprintf('\n');
  end
  fprintf('\n');
end
