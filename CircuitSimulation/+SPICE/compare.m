function compare(cards)
  modelNames = fieldnames(cards);
  modelCount = length(modelNames);

  parameters = {};
  for i = 1:modelCount
    parameters = [ parameters; fieldnames(cards.(modelNames{i})) ];
  end
  parameters = sort(unique(parameters));

  parameterCount = length(parameters);

  values = cell(parameterCount, modelCount);
  for i = 1:parameterCount
    for j = 1:modelCount
      if ~isfield(cards.(modelNames{j}), parameters{i}), continue; end
      values{i, j} = cards.(modelNames{j}).(parameters{i});
    end
  end

  fprintf('%10s', 'Parameter');
  for i = 1:modelCount
    fprintf('%15s', modelNames{i});
  end
  fprintf('\n');

  for i = 1:parameterCount
    fprintf('%10s', parameters{i});
    for j = 1:modelCount
      fprintf('%15s', String(values{i, j}));
    end
    fprintf('\n');
  end
end
