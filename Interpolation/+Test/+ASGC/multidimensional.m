function interpolant = multidimensional
  clear all;
  setup;

  samples = 1e2;

  odeOptions = odeset( ...
    'Vectorized', 'on', ...
    'AbsTol', 1e-6, ...
    'RelTol', 1e-3);

  acOptions = Options( ...
    'inputDimension', 1, ...
    'outputDimension', 3, ...
    'maxLevel', 20, ...
    'tolerance', 1e-2);

  t = 0:0.01:30;
  steps = length(t);

  z = linspace(-1, 1, samples);

  %
  % Enumeration of `all' possible scenarious.
  %
  filename = sprintf('multidimensional_steps_%d_samples_%d.mat', steps, samples);

  if exist(filename, 'file')
    load(filename);
  else
    Y = zeros(steps, 3, samples);

    tic;
    for i = 1:samples
      Y(:, :, i) = solve(t, [ 1.0, 0.1 * z(i), 0 ], odeOptions);
    end
    time = toc;

    save(filename, 'Y', 'time', '-v7.3');
  end

  fprintf('Simulation time for %d samples: %.2f s\n', samples, time);

  Variance = var(Y, [], 3);

  solutionFigure = figure;
  Plot.label('Uncertain parameter');
  Plot.title('Solution');
  plotTransient(z, transpose(squeeze(Y(end, :, :))));

  figure;
  Plot.label('Time');
  Plot.title('Variance');
  plotTransient(t, Variance);

  %
  % Adaptive sparse grid collocation.
  %

  k = steps;

  tic;
  interpolant = ASGC( ...
    @(u) solvePointwise([ 0, t(k) ], ...
      [ ones(size(u)), 0.1 * (2 * u - 1), zeros(size(u)) ], ...
      odeOptions), acOptions);
  fprintf('Interpolant construction: %.2f s\n', toc);

  plotMarkers(t(k), interpolant.variance);

  display(interpolant);
  plot(interpolant);

  figure(solutionFigure);
  plotTransient(z, interpolant.evaluate((z.' + 1) / 2), 'LineStyle', '--');
  legend('Exact 1', 'Exact 2', 'Exact 3', ...
    'Approximated 1', 'Approximated 2', 'Approximated 3');
end

function y = solve(t, y0, options)
  [ ~, y ] = ode45(@rightHandSide, t, y0, options);
end

function values = solvePointwise(t, y0, options)
  points = size(y0, 1);
  values = zeros(points, 3);
  for i = 1:points
    y = solve(t, y0(i, :), options);
    values(i, :) = y(end, :);
  end
end

function dy = rightHandSide(t, y)
  dy = [ ...
      y(1, :) .* y(3, :); ...
    - y(2, :) .* y(3, :); ...
    - y(1, :).^2 + y(2, :).^2 ];
end

function plotTransient(t, y, varargin)
  count = size(y, 2);
  for i = 1:count
    line(t, y(:, i), 'Color', Color.pick(i), varargin{:});
  end
end

function plotMarkers(t, y)
  count = length(y);
  for i = 1:count
    line([ t t ], [ y(i) y(i) ], 'LineStyle', 'None', ...
      'Marker', 'o', 'Color', Color.pick(i));
  end
end
