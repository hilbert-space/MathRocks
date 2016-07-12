function Box(varargin)
  setup;
  assess(@target, ...
    'inputCount', 2, ...
    'outputCount', 3, ...
    'maximalLevel', 4, ...
    varargin{:});
end

function y = target(x)
  x1 = x(:, 1);
  x2 = x(:, 2);
  y = [x1 + x2 > 0.5, x1 - x2 > 0.5, x2 - x1 > 0.5];
end
