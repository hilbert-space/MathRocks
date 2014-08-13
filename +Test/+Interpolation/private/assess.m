function assess(target, varargin)
  options = Options( ...
    'inputCount', 1, ...
    'outputCount', 1, ...
    'sampleCount', 1e3, ...
    'absoluteTolerance', 1e-4, ...
    'relativeTolerance', 1e-2, ...
    'maximalLevel', 10, ...
    'verbose', true, ...
    varargin{:});

  inputCount = options.inputCount;

  exactIntegral = options.get('exactIntegral', []);

  surrogate = Interpolation(options);

  time = tic;
  output = surrogate.construct(target);
  fprintf('Construction time: %.2f s\n', toc(time));

  display(surrogate, output);

  if inputCount <= 3
    surrogate.plot(output);
  end

  switch inputCount
  case 1
    if options.has('plotGrid')
      x = options.plotGrid;
    else
      x = (0:0.01:1).';
    end

    z1 = target(x);
    z2 = surrogate.evaluate(output, x);

    Plot.figure(1000, 600);

    subplot(1, 2, 1);
    Plot.line(x, z1);
    Plot.title('Exact');

    subplot(1, 2, 2);
    Plot.line(x, z2);
    Plot.title('Approximation');

    Plot.figure(1000, 600);

    Plot.line(x, abs(z1 - z2), 'number', 1);
    Plot.title('Absolute error');
  case 2
    if options.has('plotGrid')
      X = options.plotGrid{1};
      Y = options.plotGrid{2};
    else
      x = 0:0.05:1;
      y = 0:0.05:1;
      [X, Y] = meshgrid(x, y);
    end

    Z1 = zeros(size(X));
    Z2 = zeros(size(X));

    Plot.figure(1000, 600);

    Z1(:) = target([X(:) Y(:)]);
    subplot(1, 2, 1);
    mesh(X, Y, Z1);
    Plot.title('Exact');

    Z2(:) = surrogate.evaluate(output, [X(:) Y(:)]);
    subplot(1, 2, 2);
    mesh(X, Y, Z2);
    Plot.title('Approximation');

    Plot.figure(1000, 600);

    mesh(X, Y, abs(Z1 - Z2));
    Plot.title('Absolute error');
  end

  u = rand(options.sampleCount, inputCount);

  time = tic;
  mcData = target(u);
  fprintf('Monte-Carlo evaluation time: %.2f s\n', toc(time));

  time = tic;
  mcIntegral = mean(mcData);
  fprintf('Monte-Carlo analysis time: %.2f s\n', toc(time));

  time = tic;
  surrogateData = surrogate.evaluate(output, u);
  fprintf('Surrogate evaluation time: %.2f s\n', toc(time));

  names = { 'Empirical MC', 'Empirical SG', 'Analytical SG' };

  time = tic;
  surrogateIntegral = surrogate.integrate(output);
  fprintf('Surrogate analysis time: %.2f s\n', toc(time));

  integral = { mcIntegral, mean(surrogateData, 1), surrogateIntegral };

  if ~isempty(exactIntegral)
    names = ['Exact', names];
    integral = [options.exactIntegral, integral];
  end

  fprintf('Integral:\n');
  Print.crossComparison('names', names, ...
    'values', integral, 'capitalize', false);
  fprintf('\n');

  fprintf('Pointwise:\n');
  fprintf('  L2:              %e\n', ...
    Error.computeL2(mcData, surrogateData));
  fprintf('  Normalized L2:   %e\n', ...
    Error.computeNL2(mcData, surrogateData));
  fprintf('  Normalized RMSE: %e\n', ...
    Error.computeNRMSE(mcData, surrogateData));
  fprintf('  Infinity norm:   %e\n', ...
    norm(mcData - surrogateData, Inf));
end
