function ManyOutputs(varargin)
  setup;
  assess(@target, ...
    'inputCount', 2, ...
    'outputCount', 1000, ...
    'maximalLevel', 10, ...
    varargin{:});
end

function y = target(x)
  x1 = x(:, 1);
  x2 = x(:, 2);
  y = zeros(length(x1), 1000);
  for i = 1:1000
    y(:, i) = (x1 + x2) > 0.5;
  end
end
