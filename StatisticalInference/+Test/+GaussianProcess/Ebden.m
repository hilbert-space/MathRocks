function Ebden
  %
  % Reference:
  %
  % E. Ebden. Gaussian Processes for Regression: A Quick Introduction.
  % August 2008.
  %
  % http://www.robots.ox.ac.uk/~mebden/reports/GPtutorial.pdf
  %

  clear all;
  close all;

  setup;

  x = [ -1.5 -1 -.75 -.4 -.25 0 ]';
  y = .55 * [ -3 -2 -.6 .4 1 1.6 ]';
  xstar = ((1:1e3) / 1e3 * 2.1 - 1.8)';

  function [ K, dK ] = correlate(x, y, params)
    s = params(1); % Standard deviation
    l = params(2); % Length scale

    n = (x - y).^2;
    e = exp(-n / (2 * l^2));
    K = s^2 * e;

    if nargout == 1, return; end % Need derivatives?

    dK = [ 2 * s * e; l^(-3) * K .* n ];
  end

  kernel = Options( ...
    'compute', @correlate, ...
    'parameters', [ 1.0,  1.0 ], ...
    'lowerBound', [ 0.3,  0.1 ], ...
    'upperBound', [ 3.0, 10.0 ], ...
    'startCount', 5);

  surrogate = Regression.GaussianProcess( ...
    'nodes', x, 'responses', y, ...
    'kernel', kernel, 'verbose', true);

  fprintf('Found parameters: %s.\n', Utils.toString(surrogate.parameters));

  [ ystar, var ] = surrogate.evaluate(xstar);
  std = sqrt(diag(var));

  figure;
  line(x, y, 'Color', Color.pick(1), 'LineStyle', 'None', 'Marker', 'o');
  line(xstar, ystar, 'Color', Color.pick(2));
  line(xstar, ystar - std, 'Color', Color.pick(2), 'LineStyle', '--');
  line(xstar, ystar + std, 'Color', Color.pick(2), 'LineStyle', '--');
end
