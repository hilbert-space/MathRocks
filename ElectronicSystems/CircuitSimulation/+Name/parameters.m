function stamp = parameters(parameters)
  stamp = String.join('_', fieldnames(parameters));
end
