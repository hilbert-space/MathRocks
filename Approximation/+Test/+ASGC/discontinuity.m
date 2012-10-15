function discontinuity
  clear all;
  setup;

  odeOptions = odeset( ...
    'Vectorized', 'on', ...
    'AbsTol', 1e-6, ...
    'RelTol', 1e-3);

  acOptions = Options( ...
    'adaptivityControl', 'variance', ...
    'inputDimension', 1, ...
    'minLevel', 5, ...
    'maxLevel', 20, ...
    'tolerance', 1e-4);

  f = 2;
  x0 = 0.05;
  dx = 0.2;

  %
  % A small test before anything else.
  %
  t = 25;
  u = 0.375;
  y = solve([ 0 t ], [ x0 + dx * (2 * u - 1), 0 ], odeOptions, f);
  fprintf('Fixed point function value: %.e\n', y(end, 1));

  t = 0:0.001:25;
  steps = length(t);

  %
  % Enumeration of `all' possible scenarious.
  %
  z = -1:0.1:1;
  samples = length(z);

  filename = sprintf('discontinuity_steps_%d_samples_%d.mat', steps, samples);

  if exist(filename, 'file')
    load(filename);
  else
    Y = zeros(steps, samples);

    tic;
    for i = 1:samples
      Y(:, i) = solve(t, [ x0 + dx * z(i), 0 ], odeOptions, f);
    end
    time = toc;

    save(filename, 'Y', 'time', '-v7.3');
  end

  fprintf('Simulation time for %d samples: %.2f s\n', samples, time);

  [ T, Z ] = meshgrid(t, z);
  plotTransient(T, Z, Y);

  %
  % Adaptive sparse grid collocation.
  %

  k = steps;
  t = t(k);

  tic;
  interpolant = ASGC( ...
    @(u) solvePointwise([ 0, t ], ...
      [ x0 + dx * (2 * u - 1), zeros(size(u)) ], odeOptions, f), acOptions);
  fprintf('Interpolant construction: %.2f s\n', toc);

  display(interpolant);

  plot(interpolant);

  tic;
  y = interpolant.evaluate(transpose((z + 1) / 2));
  fprintf('Interpolant evaluation at %d points: %.2f s\n', samples, toc);

  plotSlice(t, z, y, Y(k, :));

  data = interpolant.evaluate(rand(10^3, 1));
  observeData(data, 'draw', true, 'method', 'histogram');
end

function y = solve(t, y0, options, f)
  [ ~, y ] = ode45(@rightHandSide, t, y0, options, f);
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

function dy = rightHandSide(t, y, f)
  dy = [ y(2, :); - f * y(2, :) - (35 / 2) * y(1, :).^3 + (15 / 2) * y(1, :) ];
end

function plotTransient(T, Z, Y)
  figure;

  meshc(T, Z, transpose(Y));
  view([ 35, 45 ]);

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
