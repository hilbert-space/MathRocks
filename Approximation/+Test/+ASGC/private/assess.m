function [ asgc, asgcOutput, mcOutput ] = assess(f, varargin)
  options = Options( ...
    'inputCount', 1, ...
    'outputCount', 1, ...
    'sampleCount', 1e3, ...
    'control', 'InfNorm', ...
    'tolerance', 1e-2, ...
    'maximalLevel', 20, ...
    'verbose', true, varargin{:});

  inputCount = options.inputCount;
  outputCount = options.outputCount;
  sampleCount = options.sampleCount;

  hasExact = options.has('exactExpectation') && options.has('exactVariance');

  u = rand(sampleCount, inputCount);

  asgc = ASGC();

  time = tic;
  asgcOutput = asgc.construct(f, options);
  fprintf('Construction time: %.2f s\n', toc(time));

  display(asgcOutput);

  switch inputCount
  case 1
    Plot.adaptiveSparseGrid(asgcOutput);
  case 2
    Plot.adaptiveSparseGrid(asgcOutput);

    x = 0:0.1:1;
    y = 0:0.1:1;
    [ X, Y ] = meshgrid(x, y);
    Z = zeros(size(X));

    figure;

    Z(:) = f([ X(:) Y(:) ]);
    subplot(1, 2, 1);
    mesh(X, Y, Z);
    Plot.title('Exact');

    Z(:) = asgc.evaluate(asgcOutput, [ X(:) Y(:) ]);
    subplot(1, 2, 2);
    mesh(X, Y, Z);
    Plot.title('Approximation');
  end

  time = tic;
  mcOutput.data = f(u);
  fprintf('MC evaluation time: %.2f s\n', toc(time));
  mcOutput.expectation = mean(mcOutput.data);
  mcOutput.variance = var(mcOutput.data);

  time = tic;
  asgcOutput.data = asgc.evaluate(asgcOutput, u);
  fprintf('ASGC evaluation time: %.2f s\n', toc(time));

  if hasExact
    printMoments('Exact', ...
      options.exactExpectation, options.exactVariance);
  end

  printMoments('MC empirical', ...
    mcOutput.expectation, mcOutput.variance, options);

  printMoments('ASGC empirical', ...
    mean(asgcOutput.data), var(asgcOutput.data), options);

  printMoments('ASGC analytical', ...
    asgcOutput.expectation, asgcOutput.variance, options);

  fprintf('MC empirical vs. ASGC empirical:\n');
  fprintf('  Expectation: %12.8f\n', ...
    mean(mcOutput.expectation - mean(asgcOutput.data)));
  fprintf('  Variance:    %12.8f\n', ...
    mean(mcOutput.variance - var(asgcOutput.data)));

  fprintf('MC empirical vs. ASGC analytical:\n');
  fprintf('  Expectation: %12.8f\n', ...
    mean(mcOutput.expectation - asgcOutput.expectation));
  fprintf('  Variance:    %12.8f\n', ...
    mean(mcOutput.variance - asgcOutput.variance));

  fprintf('MC vs. ASGC pointwise:\n');
  fprintf('  Normalized L2:   %e\n', ...
    Error.computeNL2(mcOutput.data, asgcOutput.data));
  fprintf('  Normalized RMSE: %e\n', ...
    Error.computeNRMSE(mcOutput.data, asgcOutput.data));
  fprintf('  Infinity norm:   %e\n', ...
    norm(mcOutput.data - asgcOutput.data, Inf));
end

function printMoments(name, expectation, variance, options)
  fprintf('%s:\n', name);

  if nargin > 3 && options.has('exactExpectation')
    fprintf('  Expectation: %12.8f (%12.8f)\n', ...
      mean(expectation), mean(options.exactExpectation - expectation));
  else
    fprintf('  Expectation: %12.8f\n', mean(expectation));
  end

  if nargin > 3 && options.has('exactVariance')
    fprintf('  Variance:    %12.8f (%12.8f)\n', ...
      mean(variance), mean(options.exactVariance - variance));
  else
    fprintf('  Variance:    %12.8f\n', mean(variance));
  end
end
