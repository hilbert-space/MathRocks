function plot(this, varargin)
  options = Options(varargin{:});

  if options.get('figure', true)
    Plot.figure(600, 600);
    Plot.title(class(this));
  end

  switch this.dimensionCount
  case 1
    Plot.line(this.nodes, ones(size(this.nodes)), 'discrete', true);
  case 2
    Plot.line(this.nodes(:, 1), this.nodes(:, 2), 'discrete', true);
  case 3
    Plot.line({ this.nodes(:, 1), this.nodes(:, 2) }, ...
      this.nodes(:, 3), 'discrete', true);
    view(45, 45);
  otherwise
    assert(false);
  end

  grid on;
end
