function x = constructLinearSpace(varargin)
  [left, right] = Utils.detectBounds(varargin{:});
  if left == right
    x = [left];
  else
    points = min(max((right - left) / 0.1, 1e2), 1e3);
    x = linspace(left, right, points);
  end
end
