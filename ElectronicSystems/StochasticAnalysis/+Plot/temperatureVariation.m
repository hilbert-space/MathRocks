function temperatureVariation(expectationSet, varianceSet, varargin)
  if nargin < 2
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

  names = options.get('names', cell(1, setCount));

  if options.has('time')
    time = options.time;
    labels = { 'Time, s', 'Temperature, C' };
  else
    time = 0:(stepCount - 1);
    labels = { 'Time, #', 'Temperature, C' };
  end

  switch layout
  case 'separate'
  case 'one'
    if options.get('figure', true), figure; end
    Plot.title('Temperature');
    Plot.label(labels{:});
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
      Plot.label(labels{:});
      Plot.limit(time);
      legend = {};
    case 'one'
    end

    if ~isempty(index), I = index{i}; end

    for j = 1:setCount
      switch layout
      case 'separate'
        number = j;
      otherwise
        number = i;
      end

      Plot.line(time(I), Utils.toCelsius(expectationSet{j}(i, I)), ...
        options, 'number', number);

      legend{end + 1} = names{j};
      if isempty(varianceSet{j}), continue; end

      if ~isempty(legend{end})
        legend{end} = [ legend{end}, ': ' ];
      end
      legend{end} = [ legend{end}, 'Expectation' ];

      Plot.line(time(I), Utils.toCelsius( ...
        expectationSet{j}(i, I) + sqrt(varianceSet{j}(i, I))), ...
        options, 'number', number, 'auxiliary', true);

      legend{end + 1} = names{j};
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
