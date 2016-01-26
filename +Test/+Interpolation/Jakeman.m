function Jakeman(varargin)
  %
  % Reference:
  %
  % J. Jackman and S. Roberts. "Local and Dimension Adaptive Stochastic
  % Collocation for Uncertainty Quantification." 2013
  %
  setup;
  inputCount = 10;
  assess(@target3, ...
    'inputCount', inputCount, ...
    'maximalLevel', 20, ...
    'maximalNodeCount', 100000, ...
    varargin{:});
end

function y = target3(z)
  d = size(z, 2);
  assert(d >= 2);
  w = 0.5 * ones(1, d);
  c = 1 ./ 2.^((1:d)' + 1);
  y = exp(z * c);
  y(any([z(:, 1) > w(1), z(:, 2) > w(2)], 2)) = 0;
end
