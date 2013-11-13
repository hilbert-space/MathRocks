function interpolation = assess(f, varargin)
  options = Options( ...
    'inputCount', 1, ...
    'outputCount', 1, ...
    'sampleCount', 1e3, ...
    'absoluteTolerance', 1e-4, ...
    'relativeTolerance', 1e-2, ...
    'maximalLevel', 10, ...
    'verbose', true, varargin{:});

  inputCount = options.inputCount;

  exactIntegral = options.get('exactIntegral', []);

  interpolation = Interpolation(options);

  time = tic;
  output = interpolation.construct(f);
  fprintf('Construction time: %.2f s\n', toc(time));

  display(interpolation, output);

  if inputCount <= 3
    interpolation.plot(output);
  end

  switch inputCount
  case 1
    if options.has('plotGrid')
      x = options.plotGrid;
    else
      x = (0:0.01:1).';
    end

    z1 = f(x);
    z2 = interpolation.evaluate(output, x);

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
      [ X, Y ] = meshgrid(x, y);
    end

    Z1 = zeros(size(X));
    Z2 = zeros(size(X));

    Plot.figure(1000, 600);

    Z1(:) = f([ X(:) Y(:) ]);
    subplot(1, 2, 1);
    mesh(X, Y, Z1);
    Plot.title('Exact');

    Z2(:) = interpolation.evaluate(output, [ X(:) Y(:) ]);
    subplot(1, 2, 2);
    mesh(X, Y, Z2);
    Plot.title('Approximation');

    Plot.figure(1000, 600);

    mesh(X, Y, abs(Z1 - Z2));
    Plot.title('Absolute error');
  end

  u = rand(options.sampleCount, inputCount);

  time = tic;
  mcData = f(u);
  fprintf('Monte-Carlo evaluation time: %.2f s\n', toc(time));

  time = tic;
  mcIntegral = mean(mcData);
  fprintf('Monte-Carlo analysis time: %.2f s\n', toc(time));

  time = tic;
  interpolationData = interpolation.evaluate(output, u);
  fprintf('Surrogate evaluation time: %.2f s\n', toc(time));

  names = { 'Empirical MC', 'Empirical SG', 'Analytical SG' };

  time = tic;
  interpolationIntegral = interpolation.integrate(output);
  fprintf('Surrogate analysis time: %.2f s\n', toc(time));

  integral = { mcIntegral, mean(interpolationData, 1), interpolationIntegral };

  if ~isempty(exactIntegral)
    names = [ 'Exact', names ];
    integral = [ options.exactIntegral, integral ];
  end

  fprintf('Integral:\n');
  printIntegral(names, integral);
  fprintf('\n');

  fprintf('Pointwise:\n');
  fprintf('  L2:              %e\n', ...
    Error.computeL2(mcData, interpolationData));
  fprintf('  Normalized L2:   %e\n', ...
    Error.computeNL2(mcData, interpolationData));
  fprintf('  Normalized RMSE: %e\n', ...
    Error.computeNRMSE(mcData, interpolationData));
  fprintf('  Infinity norm:   %e\n', ...
    norm(mcData - interpolationData, Inf));
end

function printIntegral(names, values)
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
