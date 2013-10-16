function [ surrogateOutput, surrogate ] = assess(f, varargin)
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

  display(Options(surrogateOutput), 'Sparse grid');

  switch inputCount
  case 1
    plot(surrogate, surrogateOutput);
    x = (0:0.01:1).';
    Plot.figure(1000, 600);
    Plot.line(x, f(x), 'number', 1);
    Plot.line(x, surrogate.evaluate(surrogateOutput, x), 'number', 2);
    Plot.legend('Exact', 'Approximation');
  case 2
    plot(surrogate, surrogateOutput);

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
  mcOutput.data = f(u);
  fprintf('MC evaluation time: %.2f s\n', toc(time));
  mcOutput.expectation = mean(mcOutput.data);
  mcOutput.variance = var(mcOutput.data);

  time = tic;
  surrogateOutput.data = surrogate.evaluate(surrogateOutput, u);
  fprintf('SG evaluation time: %.2f s\n', toc(time));

  names = { ...
    'Empirical MC', ...
    'Empirical SG', ...
    'Analytical SG' };

  expectation = { ...
    mcOutput.expectation, ...
    mean(surrogateOutput.data, 1), ...
    surrogateOutput.expectation };

  variance = { ...
    mcOutput.variance, ...
    var(surrogateOutput.data, [], 1), ...
    surrogateOutput.variance };

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
    Error.computeNL2(mcOutput.data, surrogateOutput.data));
  fprintf('  Normalized RMSE: %e\n', ...
    Error.computeNRMSE(mcOutput.data, surrogateOutput.data));
  fprintf('  Infinity norm:   %e\n', ...
    norm(mcOutput.data - surrogateOutput.data, Inf));
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
