function label(varargin)
  count = length(varargin);

  if count > 0
    xlabel(varargin{1}, 'FontSize', 14);
  end

  if count > 1
    ylabel(varargin{2}, 'FontSize', 14);
  end

  if count > 2
    zlabel(varargin{3}, 'FontSize', 14);
  end
end
