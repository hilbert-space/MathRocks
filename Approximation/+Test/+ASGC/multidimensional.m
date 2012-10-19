function interpolant = multidimensional
  setup;

  sampleCount = 1e2;

  innerTimeStep = 0.01;
  outerTimeStep = 0.1;

  time = 0:outerTimeStep:30;
  timeSpan = [ min(time), max(time) ];

  timeDivision = outerTimeStep / innerTimeStep;

  stepCount = length(time);

  inputDimension = 1;
  outputDimension = 3* stepCount;

  odeOptions = odeset( ...
    'Vectorized', 'on', ...
    'AbsTol', 1e-6, ...
    'RelTol', 1e-3);

  acOptions = Options( ...
    'InputDimension', inputDimension, ...
    'OutputDimension', outputDimension, ...
    'AdaptivityControl', 'InfNormSurpluses2', ...
    'Tolerance', 1e-2, ...
    'MaximalLevel', 20, ...
    'Verbose', true);

  z = transpose(linspace(-1, 1, sampleCount));

  %
  % Monte Carlo simulation.
  %
  filename = sprintf('ASGC_multidimensional_%s.mat', ...
    DataHash({ inputDimension, outputDimension, sampleCount }));

  if exist(filename, 'file')
    load(filename);
  else
    mcData = zeros(stepCount, 3, sampleCount);

    tic;
    for i = 1:sampleCount
      mcData(:, :, i) = solve([ 1.0, 0.1 * z(i), 0 ], ...
        timeSpan, innerTimeStep, outerTimeStep);
    end
    mcTime = toc;

    save(filename, 'mcData', 'mcTime', '-v7.3');
  end

  fprintf('Monte Carlo:\n');
  fprintf('  Samples: %d\n', sampleCount);
  fprintf('  Time:    %.2f s\n', mcTime);

  %
  % Adaptive sparse grid collocation.
  %
  tic;
  interpolant = ASGC( ...
    @(u) solveVector([ ones(size(u)), 0.1 * (2 * u - 1), zeros(size(u)) ], ...
      timeSpan, innerTimeStep, outerTimeStep, outputDimension), acOptions);

  fprintf('Adaptive sparse grid collocation:\n');
  fprintf('  Constructio time: %.2f s\n', toc);

  tic;
  scData = interpolant.evaluate((z + 1) / 2);
  fprintf('  Evaluation time:  %.2f s\n', toc);

  display(interpolant);
  plot(interpolant);

  %
  % The expected value.
  %
  figure;

  mcExpectation = mean(mcData, 3);
  scExpectation = reshape(interpolant.expectation, [ stepCount, 3 ]);

  Plot.title('Expectation');
  Plot.label('Time');
  plotTransient(time, mcExpectation);
  plotTransient(time, scExpectation, 'LineStyle', '--');

  %
  % The variance.
  %
  figure;

  mcVariance = var(mcData, [], 3);
  scVariance = reshape(interpolant.variance, [ stepCount, 3 ]);

  Plot.title('Expectation');
  Plot.label('Time');
  plotTransient(time, mcVariance);
  plotTransient(time, scVariance, 'LineStyle', '--');

  %
  % A solution slice.
  %
  figure;

  mcData = transpose(squeeze(mcData(end, :, :)));
  scData = scData(:, [ ...
    outputDimension - 2 * stepCount, ...
    outputDimension - 1 * stepCount, ...
    outputDimension - 0 * stepCount ]);

  Plot.title('Solution');
  Plot.label('Uncertain parameter');
  plotTransient(z, mcData);
  plotTransient(z, scData, 'LineStyle', '--');
end

function y = solve(y0, timeSpan, innerTimeStep, outerTimeStep)
  stepCount = timeSpan(end) / innerTimeStep;
  y = rk4(@rightHandSide, y0, timeSpan(1), innerTimeStep, stepCount);
  I = 1:(outerTimeStep / innerTimeStep):(stepCount + 1);
  y = y(I, :);
end

function Y = solveVector(y0, timeSpan, innerTimeStep, outerTimeStep, outputDimension)
  points = size(y0, 1);
  Y = zeros(points, outputDimension);
  parfor i = 1:points
    y = solve(y0(i, :), timeSpan, innerTimeStep, outerTimeStep);
    Y(i, :) = transpose(y(:));
  end
end

function dy = rightHandSide(t, y)
  dy = [ y(:, 1) .* y(:, 3), - y(:, 2) .* y(:, 3), - y(:, 1).^2 + y(:, 2).^2 ];
end

function plotTransient(t, y, varargin)
  count = size(y, 2);
  for i = 1:count
    line(t, y(:, i), 'Color', Color.pick(i), varargin{:});
  end
end

function y = rk4(f, y0, startTime, timeStep, stepCount)
  dimensionCount = length(y0);

  y = zeros(stepCount + 1, dimensionCount);
  y(1, :) = y0;

  a = [ 0 1/2 1/2 1 ];
  b = [ 0 0 0; 1/2 0 0; 0 1/2 0; 0 0 1 ];
  c = [ 1/6 1/3 1/3 1/6 ];

  stageCount = 4;
  stageY = zeros(stageCount, dimensionCount);

  t = startTime;
  for k = 2:(stepCount + 1)
    for i = 1:stageCount
      ti = t + timeStep * a(i);
      yi = y(k - 1, :);
      for j = 1:(i - 1)
        yi = yi + timeStep * b(i, j) * stageY(j, :);
      end
      stageY(i, :) = feval(f, ti, yi);
    end
    y(k, :) = y(k - 1, :) + timeStep * c * stageY;
    t = t + timeStep;
  end
end
