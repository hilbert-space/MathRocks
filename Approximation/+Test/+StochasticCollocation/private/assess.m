function [ surrogate, surrogateOutput, surrogateData ] = assess(f, varargin)
  options = Options( ...
    'inputCount', 1, ...
    'outputCount', 1, ...
    'sampleCount', 1e3, ...
    'absoluteTolerance', 1e-3, ...
    'relativeTolerance', 1e-2, ...
    'maximalLevel', 20, ...
    'verbose', true, varargin{:});

  inputCount = options.inputCount;
  sampleCount = options.sampleCount;

  hasExact = options.has('exactExpectation') && options.has('exactVariance');

  u = rand(sampleCount, inputCount);

  surrogate = instantiate(options);

  time = tic;
  surrogateOutput = surrogate.construct(f);
  fprintf('Construction time: %.2f s\n', toc(time));

  display(Options(surrogateOutput), 'Interpolation');

  if inputCount <= 3
    surrogate.plot(surrogateOutput);
  end

  switch inputCount
  case 1
    x = (0:0.01:1).';
    Plot.figure(1000, 600);
    Plot.line(x, f(x), 'number', 1);
    Plot.line(x, surrogate.evaluate(surrogateOutput, x), 'number', 2);
    Plot.legend('Exact', 'Approximation');
  case 2
    x = 0:0.05:1;
    y = 0:0.05:1;
    [ X, Y ] = meshgrid(x, y);
    Z = zeros(size(X));

    Plot.figure(1000, 600);

    Z(:) = f([ X(:) Y(:) ]);
    subplot(1, 2, 1);
    mesh(X, Y, Z);
    Plot.title('Exact');

    Z(:) = surrogate.evaluate(surrogateOutput, [ X(:) Y(:) ]);
    subplot(1, 2, 2);
    mesh(X, Y, Z);
    Plot.title('Approximation');
  end

  time = tic;
  mcData = f(u);
  fprintf('Monte-Carlo evaluation time: %.2f s\n', toc(time));

  time = tic;
  mcStats.expectation = mean(mcData);
  mcStats.variance = var(mcData);
  fprintf('Monte-Carlo analysis time: %.2f s\n', toc(time));

  time = tic;
  surrogateData = surrogate.evaluate(surrogateOutput, u);
  fprintf('Surrogate evaluation time: %.2f s\n', toc(time));

  names = { 'Empirical MC', 'Empirical SG', 'Analytical SG' };

  time = tic;
  surrogateStats = surrogate.analyze(surrogateOutput);
  fprintf('Surrogate analysis time: %.2f s\n', toc(time));

  expectation = { ...
    mcStats.expectation, ...
    mean(surrogateData, 1), ...
    surrogateStats.expectation };

  variance = { ...
    mcStats.variance, ...
    var(surrogateData, [], 1), ...
    surrogateStats.variance };

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
    Error.computeNL2(mcData, surrogateData));
  fprintf('  Normalized RMSE: %e\n', ...
    Error.computeNRMSE(mcData, surrogateData));
  fprintf('  Infinity norm:   %e\n', ...
    norm(mcData - surrogateData, Inf));
end

function printMoments(names, values)
  nameCount = length(names);

  nameWidth = -Inf;
  for i = 1:nameCount
    nameWidth = max(nameWidth, length(names{i}));
  end
  nameWidth = nameWidth + 2;

  nameFormat = [ '%', num2str(nameWidth), 's' ];
  valueFormat = [ '%', num2str(nameWidth), 'g' ];

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
        fprintf(valueFormat, ...
          abs(mean((values{i} - values{j}) ./ values{i})));
      end
    end
    fprintf('\n');
  end
end
