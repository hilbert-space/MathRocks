function lines(x, y, varargin)
  options = Options(varargin{:});

  if options.has('title')
    Plot.title(options.title);
  end

  if options.has('labels')
    Plot.label(options.labels{:});
  end

  I = options.get('index', {});
  style = options.get('style', {});

  for i = 1:size(y, 1)
    color = Color.pick(i);
    if isempty(I)
      line(x, y(i, :), 'Color', color, style{:});
    else
      line(x(I{i}), y(i, I{i}), 'Color', color, style{:});
    end
  end
end
