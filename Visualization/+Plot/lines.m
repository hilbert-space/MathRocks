function lines(x, y, varargin)
  options = Options(varargin{:});

  if options.has('title')
    Plot.title(options.title);
  end

  if options.has('labels')
    Plot.label(options.labels{:});
  end

  index = options.get('index', []);
  style = options.get('style', {});

  for i = 1:size(y, 1)
    color = Color.pick(i);
    if isempty(index)
      line(x, y(i, :), 'Color', color, style{:});
    else
      I = find(index(i, :));
      I = index(i, I);
      line(x(I), y(i, 1:length(I)), 'Color', color, style{:});
    end
  end
end
