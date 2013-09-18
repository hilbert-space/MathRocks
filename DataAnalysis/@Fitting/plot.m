function plot(this, varargin)
  options = Options(varargin{:});
  assignments = options.get('parameters', struct);

  parameters = cell(1, this.parameterCount);
  index = zeros(1, this.parameterCount);

  for i = 1:this.parameterCount
    if isfield(assignments, this.parameterNames{i})
      parameters{i} = assignments.(this.parameterNames{i});
    else
      index(i) = i;
    end
  end
  index(index == 0) = [];

  switch length(index)
  case 1
    parameters{index} = this.parameterSweeps{index};
  case 2
    [ parameters{index} ] = meshgrid(this.parameterSweeps{index});
  otherwise
    assert(false);
  end

  title = '';
  for i = 1:this.parameterCount
    if ~isempty(title), title = [ title, ', ' ]; end
    title = [ title, this.parameterNames{i} ];
    if ~any(index == i)
      title = [ title, ' = ', Utils.toString(parameters{i}) ];
      parameters{i} = parameters{i} * ones(size(parameters{index(1)}));
    end
  end
  target = this.evaluate(this.output, parameters{:});

  Plot.figure(800, 600);
  switch length(index)
  case 1
    Plot.line(parameters(index), target);
    Plot.line(parameters(index), target, 'discrete', true);
  case 2
    surfc(parameters{index}, target);
    Plot.line(parameters(index), target, 'discrete', true);
    view(-180, 0);
  otherwise
    assert(false);
  end

  grid on;

  Plot.title([ this.targetName, '(', title, ')' ]);
  Plot.label(this.parameterNames{index}, this.targetName);
end
