function display(this)
  fprintf('Options:\n');
  names = properties(this);

  for i = 1:length(names)
    name = names{i};
    value = this.(name);

    if isa(value, 'char')
      fprintf('%10s: %s\n', name, value);
    elseif isa(value, 'double')
      fprintf('%10s: %f\n', name, value);
    else
      fprintf('%10s: <...>\n', name);
    end
  end
end
