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
  case 2
    [ parameters{index} ] = meshgrid(this.parameterSweeps{index});
    for i = setdiff(1:this.parameterCount, index)
      parameters{i} = parameters{i} * ones(size(parameters{index(1)}));
    end

    target = this.evaluate(this.output, parameters{:});

    Plot.figure(800, 600);

    surfc(parameters{index}, target);
    line(parameters{index(1)}(:), parameters{index(2)}(:), target(:), ...
      'LineStyle', 'None', 'Marker', 'o', ...
      'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'b');

    Plot.title('Curve fitting');
    Plot.label(this.parameterNames{index}, this.targetName);

    grid on;
    view(-180, 0);
  otherwise
    assert(false);
  end
end
