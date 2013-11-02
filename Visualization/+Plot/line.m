function line(x, y, varargin)
  if ~isa(x, 'cell'), x = { x }; end
  x = cellfun(@(z) z(:), x, 'UniformOutput', false);
  y = y(:);

  options = Options(varargin{:});

  number = options.get('number', 1);

  style = {};

  style = [ style, 'Color', Color.pick(number) ];

  if options.get('auxiliary', false)
    style = [ style, 'LineStyle', '--' ];
  elseif options.get('discrete', false);
    style = [ style, ...
      'LineStyle', 'None', ...
      'Marker', Marker.pick(number), ...
      'MarkerEdgeColor', 'w', ...
      'MarkerFaceColor', Color.pick(number) ];
  else
    style = [ style, 'LineStyle', '-' ];
  end

  if options.has('style')
    style = [ style, options.style{:} ];
  end

  line(x{:}, y, style{:});

  if ~options.has('markEach'), return; end

  x = cellfun(@(z) z(1:options.markEach:end), x, 'UniformOutput', false);
  y = y(1:options.markEach:end);

  h = line(x{:}, y, 'LineStyle', 'None', ...
    'Marker', Marker.pick(number), 'MarkerSize', 10, style{:});

  set(get(get(h, 'Annotation'), 'LegendInformation'), ...
    'IconDisplayStyle', 'off');
end
