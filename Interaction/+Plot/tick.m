function tick(varargin)
  count = length(varargin);

  if count >= 1 && ~isempty(varargin{1})
    set(gca, 'XTick', varargin{1}, 'FontSize', 16);
  end

  if count >= 2 && ~isempty(varargin{2})
    set(gca, 'XTickLabel', varargin{2});
  end

  if count >= 3 && ~isempty(varargin{3})
    set(gca, 'YTick', varargin{3}, 'FontSize', 16);
  end

  if count >= 4 && ~isempty(varargin{4})
    set(gca, 'YTickLabel', varargin{4});
  end

  if count >= 5 && ~isempty(varargin{5})
    set(gca, 'ZTick', varargin{5}, 'FontSize', 16);
  end

  if count >= 6 && ~isempty(varargin{6})
    set(gca, 'ZTickLabel', varargin{6});
  end
end
