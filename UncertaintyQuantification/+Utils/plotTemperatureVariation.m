function plotTemperatureVariation(time, expectationSet, varianceSet, varargin)
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
  processorCount = size(expectationSet{1}, 1);

  labels = options.get('labels', cell(1, setCount));

  switch layout
  case 'separate'
  case 'one'
    figure;
    Plot.title('Temperature');
    Plot.label('Time, s', 'Temperature, C');
    Plot.limit(time);
    legend = {};
  otherwise
    assert(false);
  end

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

    for j = 1:setCount
      switch layout
      case 'separate'
        color = Color.pick(j);
      otherwise
        color = Color.pick(i);
      end

      line(time, Utils.toCelsius(expectationSet{j}(i, :)), ...
        'Color', color, 'LineWidth', 1);

      legend{end + 1} = labels{j};
      if isempty(varianceSet{j}), continue; end

      legend{end} = [ legend{end}, ': Expectation' ];

      line(time, Utils.toCelsius( ...
        expectationSet{j}(i, :) + sqrt(varianceSet{j}(i, :))), ...
        'Color', color, 'LineStyle', '--');

      legend{end + 1} = sprintf('%s: Deviation', labels{j});
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
