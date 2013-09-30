function stamp = parameters(parameters)
  chunks = {};

  names = fieldnames(parameters);
  for i = 1:length(names)
    chunks{end + 1} = names{i};
    chunks{end + 1} = parameters.(names{i}).nominal;
  end

  stamp = String.join('_', chunks);
end
