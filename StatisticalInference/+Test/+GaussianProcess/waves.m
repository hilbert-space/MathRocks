function waves
  clear all;
  close all;

  setup;

  a = -10;
  b = +10;

  function y = target(x)
    y = 4 * x.^2 + 20 * sin(2 * x) - 14 * x + 1;
  end

  function [ K, dK ] = correlate(x, y, params)
    s = params(1); % Standard deviation
    l = params(2); % Length scale

    n = sum((x - y).^2, 1);
    e = exp(-n / 2 / l^2);
    K = s^2 * e;

    if nargout == 1, return; end % Need derivatives?

    dK = [ 2 * s * K; l^(-3) * K .* n ];
  end

  kernel = Options( ...
    'compute', @correlate, ...
    'parameters', [ 1.00, 0.20 ], ...
    'lowerBound', [ 0.01, 0.01 ], ...
    'upperBound', [ 5.00, 5.00 ], ...
    'startCount', 10);

  surrogate = Regression.GaussianProcess( ...
    'target', @(u) target(a + (b - a) * u), ...
    'kernel', kernel, 'nodeCount', 20, 'verbose', true);

  x = linspace(a, b, 50)';

  y1 = target(x);
  [ y2, variance ] = surrogate.evaluate((x - a) / (b - a));

  deviation = sqrt(diag(variance));

  figure;
  line(x, y1, 'Color', Color.pick(1));
  line(x, y2, 'Color', Color.pick(2));
  line(x, y2 + deviation, 'Color', Color.pick(2), 'LineStyle', '--');
  line(x, y2 - deviation, 'Color', Color.pick(2), 'LineStyle', '--');
end
