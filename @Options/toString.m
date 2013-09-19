function line = toString(this)
  line = '';
  names = sort(this.names);
  for i = 1:length(names)
    chunk = sprintf('%s:%s', names{i}, ...
      Utils.toString(this.values(names{i})));
    if i == 1
      line = chunk;
    else
      line = [ line, ';', chunk ];
    end
  end
end
