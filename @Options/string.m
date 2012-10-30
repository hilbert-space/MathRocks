function line = string(this)
  line = '';
  names = sort(properties(this));

  for i = 1:length(names)
    name = names{i};
    value = this.(name);

    if isa(value, 'Options')
      chunk = sprintf('%s_%s', name, string(value));
    else
      chunk = sprintf('%s_%s', name, Utils.toString(value));
    end

    if i == 1
      line = chunk;
    else
      line = [ line, '_', chunk ];
    end
  end
end
