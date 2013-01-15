function interpolant = multidimensional
  setup;

  sampleCount = 1e2;

  innerTimeStep = 0.01;
  outerTimeStep = 0.1;

  time = outerTimeStep:outerTimeStep:30;
  timeSpan = [ 0, max(time) ];

  timeDivision = outerTimeStep / innerTimeStep;

  stepCount = length(time);

  inputCount = 1;
  outputCount = 3 * stepCount;

  odeOptions = odeset( ...
    'Vectorized', 'on', ...
    'AbsTol', 1e-6, ...
    'RelTol', 1e-3);

  acOptions = Options( ...
    'inputCount', inputCount, ...
    'outputCount', outputCount, ...
    'control', 'InfNormSurpluses2', ...
    'tolerance', 1e-2, ...
    'maximalLevel', 20, ...
    'verbose', true);

  z = transpose(linspace(-1, 1, sampleCount));

  %
  % Monte Carlo simulation.
  %
  filename = File.temporal(sprintf('ASGC_multidimensional_%s.mat', ...
    DataHash({ inputCount, outputCount, sampleCount })));

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
      timeSpan, innerTimeStep, outerTimeStep, outputCount), acOptions);
  fprintf('Adaptive sparse grid collocation:\n');
  fprintf('  Construction time: %.2f s\n', toc);

  tic;
  scData = interpolant.evaluate((z + 1) / 2);
  fprintf('  Evaluation time:   %.2f s\n', toc);

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
    outputCount - 2 * stepCount, ...
    outputCount - 1 * stepCount, ...
    outputCount - 0 * stepCount ]);

  Plot.title('Solution');
  Plot.label('Uncertain parameter');
  plotTransient(z, mcData);
  plotTransient(z, scData, 'LineStyle', '--');

  fprintf('Infinity norm:   %e\n', norm(mcData - scData, Inf));
  fprintf('Normalized RMSE: %e\n', Error.computeNRMSE(mcData, scData));
  fprintf('Normalized L2:   %e\n', Error.computeNL2(mcData, scData));
end

function y = solve(y0, timeSpan, innerTimeStep, outerTimeStep)
  stepCount = timeSpan(end) / innerTimeStep;
  y = rk4(@rightHandSide, y0, timeSpan(1), innerTimeStep, stepCount);
  y = y(1:(outerTimeStep / innerTimeStep):stepCount, :);
end

function Y = solveVector(y0, timeSpan, innerTimeStep, outerTimeStep, outputCount)
  points = size(y0, 1);
  Y = zeros(points, outputCount);
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

function y = rk4(f, y0, t, h, count)
  y = zeros(count, length(y0));
  for k = 1:count
    f1 = feval(f, t      , y0             );
    f2 = feval(f, t + h/2, y0 + (h/2) * f1);
    f3 = feval(f, t + h/2, y0 + (h/2) * f2);
    f4 = feval(f, t + h  , y0 +  h    * f3);
    y0 = y0 + (h/6) * (f1 + 2*f2 + 2*f3 + f4);
    y(k, :) = y0;
    t = t + h;
  end
end
