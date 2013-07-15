function line = toString(this)
  line = '';
  names = sort(properties(this));
  for i = 1:length(names)
    chunk = sprintf('%s:%s', names{i}, ...
      Utils.toString(this.(names{i})));
    if i == 1
      line = chunk;
    else
      line = [ line, ';', chunk ];
    end
  end
end
