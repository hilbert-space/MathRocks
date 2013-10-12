function assessKraichnanOrszag
  setup;

  sampleCount = 1e2;

  innerTimeStep = 0.01;
  outerTimeStep = 0.1;

  time = outerTimeStep:outerTimeStep:30;
  timeSpan = [ 0, max(time) ];

  stepCount = length(time);

  inputCount = 1;
  outputCount = 3 * stepCount;

  asgcOptions = Options( ...
    'inputCount', inputCount, ...
    'outputCount', outputCount, ...
    'absoluteTolerance', 1e-2, ...
    'maximalLevel', 20);

  %
  % Brute-force exploration
  %
  z = transpose(linspace(-1, 1, sampleCount));

  Y = zeros(stepCount, 3, sampleCount);

  tic;
  for i = 1:sampleCount
    Y(:, :, i) = solve([ 1.0, 0.1 * z(i), 0 ], ...
      timeSpan, innerTimeStep, outerTimeStep);
  end
  fprintf('Computation time of %d samples: %.2f s\n', ...
    sampleCount, toc);

  %
  % Adaptive sparse grid collocation
  %
  target = @(u) solveVector([ ones(size(u)), 0.1 * (2 * u - 1), zeros(size(u)) ], ...
    timeSpan, innerTimeStep, outerTimeStep, outputCount);

  asgc = ASGC(asgcOptions);

  tic;
  asgcOutput = asgc.construct(target);
  fprintf('Construction time: %.2f s\n', toc);

  %
  % The expected value
  %
  figure;

  Plot.title('Expectation');
  Plot.label('Time');
  plotTransient(time, mean(Y, 3));
  plotTransient(time, reshape(asgcOutput.expectation, ...
    [ stepCount, 3 ]), 'LineStyle', '--');

  %
  % The variance
  %
  figure;

  Plot.title('Variance');
  Plot.label('Time');
  plotTransient(time, var(Y, [], 3));
  plotTransient(time, reshape(asgcOutput.variance, ...
    [ stepCount, 3 ]), 'LineStyle', '--');

  %
  % A solution slice
  %
  figure;

  Y = transpose(squeeze(Y(end, :, :)));
  y = asgc.evaluate(asgcOutput, (z + 1) / 2);
  y = y(:, [ ...
    outputCount - 2 * stepCount, ...
    outputCount - 1 * stepCount, ...
    outputCount - 0 * stepCount ]);

  Plot.title('Solution');
  Plot.label('Uncertain parameter');
  plotTransient(z, Y);
  plotTransient(z, y, 'LineStyle', '--');
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

function dy = rightHandSide(~, y)
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
