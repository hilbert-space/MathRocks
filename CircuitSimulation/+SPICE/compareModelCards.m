function compareModelCards(cards)
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
    highlight = false;
    for j = 2:modelCount
      if isempty(values{i, j - 1}) || isempty(values{i, j}) || ...
        any(values{i, j - 1} ~= values{i, j})

        highlight = true;
        break;
      end
    end
    if highlight
      cprintf('red', '%10s', parameters{i});
    else
      fprintf('%10s', parameters{i});
    end
    for j = 1:modelCount
      fprintf('%15s', String(values{i, j}));
    end
    fprintf('\n');
  end
end
