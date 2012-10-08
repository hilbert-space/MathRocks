function x = constructLinearSpace(varargin)
  [ data, options ] = Options.extract(varargin{:});
  [ left, right ] = Statistics.detectBounds(varargin{:});
  if left == right
    x = [ left ];
  else
    points = options.get('points', max((right - left) / 0.1, 100));
    x = linspace(left, right, points);
  end
end
