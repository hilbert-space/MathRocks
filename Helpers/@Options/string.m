function line = string(this)
  line = '';
  names = sort(properties(this));

  for i = 1:length(names)
    name = names{i};
    value = this.(name);

    if isa(value, 'char')
      chunk = sprintf('%s_%s', name, value);
    elseif isa(value, 'double')
      chunk = sprintf('%s_%d', name, value);
    elseif isa(value, 'Options')
      chunk = sprintf('%s_%s', name, string(value));
    else
      continue;
    end

    if i == 1
      line = chunk;
    else
      line = [ line, '_', chunk ];
    end
  end
end
