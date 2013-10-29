function Hat(varargin)
  setup;
  assess(@(x) problem(5 * x - 1), varargin{:});
end

function y = problem(x)
  y = zeros(size(x));
  I = logical((0 <= x) .* (x < 1));
  y(I) = (1/2) * x(I).^2;
  I = logical((1 <= x) .* (x < 2));
  y(I) = (1/2) * (-2 * x(I).^2 + 6 * x(I) - 3);
  I = logical((2 <= x) .* (x < 3));
  y(I) = (1/2) * (3 - x(I)).^2;
end
