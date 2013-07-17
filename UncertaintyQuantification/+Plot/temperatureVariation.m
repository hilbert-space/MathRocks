function temperatureVariation(time, expectationSet, varianceSet, varargin)
  if nargin < 3
    varianceSet = [];
    varargin = {};
  end

  options = Options(varargin{:});

  if ~isa(expectationSet, 'cell')
    expectationSet = { expectationSet };
    varianceSet = { varianceSet };
  end

  layout = options.get('layout', 'separate');

  setCount = length(expectationSet);
  [ processorCount, stepCount ] = size(expectationSet{1});

  labels = options.get('labels', cell(1, setCount));

  switch layout
  case 'separate'
  case 'one'
    if options.get('figure', true), figure; end
    Plot.title('Temperature');
    Plot.label('Time, s', 'Temperature, C');
    Plot.limit(time);
    legend = {};
  otherwise
    assert(false);
  end

  index = options.get('index', {});
  I = 1:stepCount;

  for i = 1:processorCount
    switch layout
    case 'separate'
      figure;
      Plot.title('Temperature %d', i);
      Plot.label('Time, s', 'Temperature, C');
      Plot.limit(time);
      legend = {};
    case 'one'
    end

    if ~isempty(index), I = index{i}; end

    for j = 1:setCount
      switch layout
      case 'separate'
        color = Color.pick(j);
      otherwise
        color = Color.pick(i);
      end

      line(time(I), Utils.toCelsius(expectationSet{j}(i, I)), ...
        'Color', color, 'LineWidth', 1);

      legend{end + 1} = labels{j};
      if isempty(varianceSet{j}), continue; end

      if ~isempty(legend{end})
        legend{end} = [ legend{end}, ': ' ];
      end
      legend{end} = [ legend{end}, 'Expectation' ];

      line(time(I), Utils.toCelsius( ...
        expectationSet{j}(i, I) + sqrt(varianceSet{j}(i, I))), ...
        'Color', color, 'LineStyle', '--');

      legend{end + 1} = labels{j};
      if ~isempty(legend{end})
        legend{end} = [ legend{end}, ': ' ];
      end
      legend{end} = [ legend{end}, 'Deviation' ];
    end

    switch layout
    case 'separate'
      Plot.legend(legend{:});
    case 'one'
    end
  end

  switch layout
  case 'separate'
  case 'one'
    Plot.legend(legend{:});
  end
end
