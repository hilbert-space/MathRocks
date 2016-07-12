function line = toString(this)
  line = '';
  names = sort(this.names__);
  for i = 1:length(names)
    chunk = sprintf('%s: %s', names{i}, String(this.values__(names{i})));
    if i == 1
      line = chunk;
    else
      line = [line, '; ', chunk];
    end
  end
end
