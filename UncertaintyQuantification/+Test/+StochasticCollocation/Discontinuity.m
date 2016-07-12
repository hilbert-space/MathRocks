function Discontinuity(varargin)
  setup;

  odeOptions = odeset( ...
    'Vectorized', 'on', ...
    'AbsTol', 1e-6, ...
    'RelTol', 1e-3);

  surrogateOptions = Options( ...
    'inputCount', 1, ...
    'absoluteTolerance', 1e-4, ...
    'minimalLevel', 5, ...
    'maximalLevel', 20, ...
    varargin{:});

  f = 2;
  x0 = 0.05;
  dx = 0.2;
  t = 0:0.001:25;
  stepCount = length(t);

  %
  % Brute-force exploration
  %
  z = -1:0.1:1;
  sampleCount = length(z);

  Y = zeros(stepCount, sampleCount);

  time = tic;
  for i = 1:sampleCount
    Y(:, i) = solve(t, [x0 + dx * z(i), 0], odeOptions, f);
  end
  fprintf('Computation time of %d samples: %.2f s\n', ...
    sampleCount, toc(time));

  [T, Z] = meshgrid(t, z);
  plotTransient(T, Z, Y);

  %
  % Adaptive sparse grid collocation
  %
  k = stepCount;
  t = t(k);

  target = @(u) solvePointwise([0, t], ...
    [x0 + dx * (2 * u - 1), zeros(size(u))], odeOptions, f);

  [surrogate, surrogateOutput, surrogateData] = assess(target, ...
    surrogateOptions, ...
    'sampleCount', sampleCount, ...
    'exactExpectation', sqrt(15 / 35) / 4, ...
    'exactVariance', 45 / 112);

  y = surrogate.evaluate(surrogateOutput, transpose((z + 1) / 2));
  plotSlice(t, z, y, Y(k, :));

  Plot.distribution(surrogateData, 'method', 'histogram');
  Plot.title('Histogram');
end

function y = solve(t, y0, options, f)
  [~, y] = ode45(@rightHandSide, t, y0, options, f);
  y = y(:, 1);
end

function values = solvePointwise(t, y0, options, f)
  points = size(y0, 1);
  values = zeros(points, 1);
  for i = 1:points
    y = solve(t, y0(i, :), options, f);
    values(i) = y(end, 1);
  end
end

function dy = rightHandSide(~, y, f)
  dy = [y(2, :); - f * y(2, :) - (35 / 2) * y(1, :).^3 + (15 / 2) * y(1, :)];
end

function plotTransient(T, Z, Y)
  figure;

  meshc(T, Z, transpose(Y));
  view([35, 45]);

  Plot.title('Transient solution');
  Plot.label('Time', 'Uncertain parameter', 'Solution');
end

function plotSlice(t, z, y, y0)
  figure;

  line(z, y, 'Color', Color.pick(1));
  Plot.title('Solution at time %.2f s', t);
  Plot.label('Uncertain parameter', 'Solution');

  if nargin > 3
    line(z, y0, 'Color', Color.pick(2));
    legend('Approximated', 'Exact');
  end
end
