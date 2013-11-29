function statistic(x, data, varargin)
  options = Options('method', 'smooth', varargin{:});

  if ~iscell(data), data = { data }; end

  switch options.method
  case { 'smooth', 'piecewise' }
    plotLines(x, data, options);
  case 'histogram'
    plotHistogram(x, data, options);
  otherwise
    error('The method is unknown.');
  end
end

function plotHistogram(x, data, options)
  hold on;
  for i = 1:length(data)
    plotBar(x, data{i}, options.get('color', Color.pick(i)));
  end
end

function plotBar(x, data, color)
  bar(x, data, 'FaceColor', color, 'Edgecolor', color);
  hpatch = findobj(gca, 'Type', 'patch');
  set(hpatch, 'FaceAlpha', 0.75);
end

function plotLines(x, data, options)
  count = length(data);
  styles = options.get('styles', {});

  if isempty(styles)
    for i = 1:count
      line(x, data{i}, 'Color', options.get('color', Color.pick(i)));
    end
  else
    for i = 1:count
      style = styles{i};
      line(x, data{i}, style{:});
    end
  end
end
