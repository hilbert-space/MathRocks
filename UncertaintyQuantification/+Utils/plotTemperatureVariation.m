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
      Plot.title('Temperature');
      Plot.label('Time, s', 'Temperature, C');
      Plot.limit(time);
      legend = {};
    case 'one'
    end

    color = Color.pick(i);
    for j = 1:setCount
      line(time, expectationSet{j}(i, :), ...
        'Color', color, 'LineWidth', 1);

      if ~isempty(labels{j})
        prefix = sprintf('%s: ', labels{j});
      else
        prefix = '';
      end

      if isempty(varianceSet{j})
        legend{end + 1} = sprintf('%sPE%d', prefix, i);
        continue;
      else
        legend{end + 1} = sprintf('%sPE%d: Expectation', prefix, i);
      end

      line(time, expectationSet{j}(i, :) + sqrt(varianceSet{j}(i, :)), ...
        'Color', color, 'LineStyle', '--');
      legend{end + 1} = sprintf('%sPE%d: Deviation', prefix, i);
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
