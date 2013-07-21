function vline(x, varargin)
  y = ylim;
  for i = 1:length(x)
    line([ x(i), x(i) ], y, varargin{:});
  end
end
