function hline(y, varargin)
  x = xlim;
  for i = 1:length(y)
    Plot.line(x, [ y(i), y(i) ], varargin{:});
  end
end
