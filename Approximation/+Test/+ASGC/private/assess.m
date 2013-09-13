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

  display(Options(asgcOutput), 'Adaptive sparse grid');

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

  names = { ...
    'Empirical MC', ...
    'Empirical ASGC', ...
    'Analytical ASGC' };

  expectation = { ...
    mcOutput.expectation, ...
    mean(asgcOutput.data, 1), ...
    asgcOutput.expectation };

  variance = { ...
    mcOutput.variance, ...
    var(asgcOutput.data, [], 1), ...
    asgcOutput.variance };

  if hasExact
    names = [ 'Exact', names ];
    expectation = [ options.exactExpectation, expectation ];
    variance = [ options.exactVariance, variance ];
  end

  fprintf('Expectation:\n');
  printMoments(names, expectation);
  fprintf('\n');

  fprintf('Variance:\n');
  printMoments(names, variance);
  fprintf('\n');

  fprintf('Pointwise:\n');
  fprintf('  Normalized L2:   %e\n', ...
    Error.computeNL2(mcOutput.data, asgcOutput.data));
  fprintf('  Normalized RMSE: %e\n', ...
    Error.computeNRMSE(mcOutput.data, asgcOutput.data));
  fprintf('  Infinity norm:   %e\n', ...
    norm(mcOutput.data - asgcOutput.data, Inf));
end

function printMoments(names, values)
  nameCount = length(names);

  nameWidth = -Inf;
  for i = 1:nameCount
    nameWidth = max(nameWidth, length(names{i}));
  end
  nameWidth = nameWidth + 2;

  nameFormat = [ '%', num2str(nameWidth), 's' ];
  valueFormat = [ '%', num2str(nameWidth), '.8f' ];

  fprintf(nameFormat, '');
  fprintf(nameFormat, 'Value');
  fprintf(' | ');
  for i = 1:nameCount
    fprintf(nameFormat, names{i});
  end
  fprintf('\n');

  for i = 1:nameCount
    fprintf(nameFormat, names{i});
    fprintf(valueFormat, mean(values{i}));
    fprintf(' | ');
    for j = 1:nameCount
      if i == j
        fprintf(nameFormat, '-');
      else
        fprintf(valueFormat, mean(values{i} - values{j}));
      end
    end
    fprintf('\n');
  end
end
