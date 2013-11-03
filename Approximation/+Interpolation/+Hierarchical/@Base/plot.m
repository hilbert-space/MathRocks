function plot(~, varargin)
  options = Options(varargin{:});

  if options.has('nodes')
    style = @(color) { 'MarkerSize', 5, 'MarkerFaceColor', color, ...
      'MarkerEdgeColor', color };

    mapping = options.get('nodeMapping', ...
      ones(size(options.nodes, 1), 1));
    levels = transpose(unique(mapping(:), 'sorted'));

    Plot.figure(600, 600);
    Plot.title('Interpolation grid');
    draw(options.nodes, levels, mapping, style);
  end

  if options.has('indexes')
    style = @(color) { 'MarkerSize', 10, 'MarkerFaceColor', color, ...
      'MarkerEdgeColor', color, 'Marker', 's' };

    mapping = options.get('indexMapping', ...
      ones(size(options.indexes, 1), 1));
    levels = transpose(unique(mapping(:), 'sorted'));

    Plot.figure(400, 400);
    Plot.title('Interpolation index');
    draw(options.indexes, levels, mapping, style);
  end
end

function draw(quantity, levels, mapping, style)
  inputCount = size(quantity, 2);

  switch inputCount
  case 1
    color = 'k';
    for i = levels
      if i == levels(end), color = 'r'; end
      I = mapping == i;
      Plot.line(quantity(I), i * ones(size(nnz(I), 1)), ...
        'discrete', true, 'style', style(color));
    end
    if isinteger(quantity)
      Plot.tick(unique(quantity), [], levels, []);
    end
  case 2
    I = mapping ~= levels(end);
    Plot.line(quantity(I, 1), quantity(I, 2), ...
      'discrete', true, 'style', style('k'));
    I = mapping == levels(end);
    Plot.line(quantity(I, 1), quantity(I, 2), ...
      'discrete', true, 'style', style('r'));
    if isinteger(quantity)
      Plot.tick(unique(quantity(:, 1)), [], ...
        unique(quantity(:, 2)), []);
    end
  case 3
    I = mapping ~= levels(end);
    Plot.line({ quantity(I, 1), quantity(I, 2) }, quantity(I, 3), ...
      'discrete', true, 'style', style('k'));
    I = mapping == levels(end);
    Plot.line({ quantity(I, 1), quantity(I, 2) }, quantity(I, 3), ...
      'discrete', true, 'style', style('r'));
    view(-45, 45);
    if isinteger(quantity)
      Plot.tick(unique(quantity(:, 1)), [], ...
        unique(quantity(:, 2)), [], unique(quantity(:, 3)), []);
    end
  otherwise
    assert(false);
  end
end
