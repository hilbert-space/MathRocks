function statistic(x, Y, varargin)
  options = Options('method', 'smooth', varargin{:});

  if ~iscell(Y), Y = { Y }; end

  switch options.method
  case { 'smooth', 'piecewise' }
    plotLines(x, Y, options);
  case 'histogram'
    plotHistogram(x, Y, options);
  otherwise
    error('The method is unknown.');
  end
end

function plotHistogram(x, Y, options)
  hold on;
  for i = 1:length(Y)
    plotBar(x, Y{i}, options.get('color', Color.pick(i)));
  end
end

function plotBar(x, Y, color)
  bar(x, Y, 'FaceColor', color, 'Edgecolor', color);
  hpatch = findobj(gca, 'Type', 'patch');
  set(hpatch, 'FaceAlpha', 0.75);
end

function plotLines(x, Y, options)
  count = length(Y);
  styles = options.get('styles', {});

  if isempty(styles)
    for i = 1:count
      line(x, Y{i}, 'Color', options.get('color', Color.pick(i)));
    end
  else
    for i = 1:count
      style = styles{i};
      line(x, Y{i}, style{:});
    end
  end
end
