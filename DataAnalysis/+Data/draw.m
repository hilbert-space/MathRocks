function draw(x, varargin)
  [ data, options ] = Options.extract(varargin{:});
  options = Options('method', 'smooth', options);

  switch options.method
  case { 'smooth', 'piecewise' }
    drawLines(x, data, options);
  case 'histogram'
    drawHistogram(x, data, options);
  otherwise
    error('The method is unknown.');
  end
end

function drawHistogram(x, data, options)
  hold on;
  for i = 1:length(data)
    drawBar(x, data{i}, options.get('color', Color.pick(i)));
  end
end

function drawBar(x, data, color)
  hbar = bar(x, data, 'FaceColor', color, 'Edgecolor', color);
  hpatch = findobj(gca, 'Type', 'patch');
  set(hpatch, 'FaceAlpha', 0.75);
end

function drawLines(x, data, options)
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
