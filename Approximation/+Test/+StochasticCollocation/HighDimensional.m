function HighDimensional(varargin)
  %
  % Reference:
  %
  % A. Klimke. Sparse Grid Interpolation Toolbox.
  %
  % http://www.ians.uni-stuttgart.de/spinterp/help/dimension-adaptive.html
  %
  % The test function is due to Arnold Neumaier, listed
  % on the global optimization web page:
  %
  % http://www.mat.univie.ac.at/~neum/glopt/
  %
  setup;

  assess(@problem, ...
    'surrogate', 'Global', ...
    'basis', 'ChebyshevLagrange', ...
    'inputCount', 100, ...
    'maximalLevel', 10, ...
    'maximalNodeCount', 4e4, ...
    'adaptivityDegree', 1, ...
    'relativeTolerance', 1e-3, ...
    'sampleCount', 1e2, ...
    varargin{:});
end

function y = problem(x)
  d = size(x, 2);
  x = 2 * d^2 * x - d^2;
  y = sum((x - 1).^2, 2) - sum(x(:, 2:d) .* x(:, 1:(d - 1)), 2);
end