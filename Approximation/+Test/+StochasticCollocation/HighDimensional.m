function HighDimensional(varargin)
  setup;
  assess(@problem, ...
    'inputCount', 100, ...
    'maximalLevel', 10, ...
    'maximalNodeCount', 4e4, ...
    'adaptivityDegree', 1, ...
    'relativeTolerance', 1e-3, ...
    varargin{:});
end

function y = problem(x)
  %
  % The test function is due to Arnold Neumaier, listed
  % on the global optimization web page:
  %
  % http://www.mat.univie.ac.at/~neum/glopt/
  %
  d = size(x, 2);
  x = 2 * d^2 * x - d^2;
  y = sum((x - 1).^2, 2) - sum(x(:, 2:d) .* x(:, 1:(d - 1)), 2);
end