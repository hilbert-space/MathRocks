function drawData(x, varargin)
  [ data, options ] = Options.extract(varargin{:});
  method = options.get('method', 'smooth');

  switch method
  case 'smooth'
    drawLines(x, data, options);
  case 'histogram'
    drawHistogram(x, data, options);
  case 'piecewise'
    drawLines(x, data, options);
  otherwise
    error('The method is unknown.');
  end
end

function drawHistogram(x, data, options)
  hold on;
  for i = 1:length(data)
    drawBar(x, data{i}, Color.pick(i));
  end
end

function drawBar(x, data, color)
  hbar = bar(x, data, 'FaceColor', color, 'Edgecolor', color);
  hpatch = findobj(gca, 'Type', 'patch');
  set(hpatch, 'FaceAlpha', 0.75);
end

function drawLines(x, data, options)
  for i = 1:length(data)
    line(x, data{i}, 'Color', Color.pick(i));
  end
end
