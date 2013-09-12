function line(x, y, varargin)
  options = Options(varargin{:});
  number = options.get('number', 1);

  style = {};

  style = [ style, 'LineWidth', 2 ];
  style = [ style, 'Color', Color.pick(number) ];

  if options.get('auxiliary', false)
    style = [ style, 'LineStyle', '--' ];
  else
    style = [ style, 'LineStyle', '-' ];
  end

  line(x, y, style{:});

  if ~options.has('markEach'), return; end

  division = options.markEach;

  line(x(1:division:end), y(1:division:end), style{:}, 'LineStyle', 'None', ...
    'Marker', Marker.pick(number), 'MarkerSize', 16);
end
