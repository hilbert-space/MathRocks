function plot(this, varargin)
  options = Options(varargin{:});
  assignments = options.get('parameters', struct);

  parameterCount = this.parameterCount;
  parameters = cell(1, parameterCount);
  index = zeros(1, parameterCount);

  for i = 1:parameterCount
    if isfield(assignments, this.parameterNames{i})
      parameters{i} = assignments.(this.parameterNames{i});
    else
      index(i) = i;
    end
  end
  index(index == 0) = [];

  exactTarget = [];
  if options.has('grid');
    grid = options.grid;

    I = setdiff(1:parameterCount, index);
    J = false(length(grid.targetData(:)), length(I));
    for i = 1:length(I)
      J(:, i) = grid.parameterData{i}(:) == parameters{I(i)};
    end
    J = all(J, 2);

    switch length(index)
    case 1
      exactTarget = grid.targetData(J);
      parameters{index} = grid.parameterData{index}(J);
    case 2
      dimensions = cellfun(@length, grid.parameterSweeps(index));
      exactTarget = reshape(grid.targetData(J), dimensions);
      for i = index
        parameters{i} = reshape(grid.parameterData{i}(J), dimensions);
      end
    otherwise
      assert(false);
    end
  else
    switch length(index)
    case 1
      parameters{index} = this.parameterSweeps{index};
    case 2
      [ parameters{index} ] = ndgrid(this.parameterSweeps{index});
    otherwise
      assert(false);
    end
  end

  title = '';
  for i = 1:parameterCount
    if ~isempty(title), title = [ title, ', ' ]; end
    title = [ title, this.parameterNames{i} ];
    if ~any(index == i)
      title = [ title, ' = ', Utils.toString(parameters{i}) ];
      parameters{i} = parameters{i} * ones(size(parameters{index(1)}));
    end
  end
  target = this.evaluate(this.output, parameters{:});

  if options.get('figure', true)
    Plot.figure(800, 600);
  end

  switch length(index)
  case 1
    Plot.line(parameters(index), target);
    Plot.line(parameters(index), target, 'discrete', true);
    if ~isempty(exactTarget)
      Plot.line(parameters(index), exactTarget, ...
        'discrete', true, 'number', 2);
    end
  case 2
    surfc(parameters{index}, target);
    Plot.line(parameters(index), target, 'discrete', true);
    if ~isempty(exactTarget)
      Plot.line(parameters(index), exactTarget, ...
        'discrete', true, 'number', 2);
    end
    view(-180, 0);
  otherwise
    assert(false);
  end

  evalin('base', 'grid on');

  Plot.title([ this.targetName, '(', title, ')' ]);
  Plot.label(this.parameterNames{index}, this.targetName);
end
