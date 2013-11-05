function options = parseHotSpot(filename)
  fid = fopen(filename, 'r');

  while true
    line = fgetl(fid);
    if ~ischar(line), break; end

    tokens = regexp(line, '^\s*-(\w+)\s+(.+)$', 'tokens');

    if isempty(tokens), continue; end

    name = tokens{1}{1};
    value = str2num(tokens{1}{2});
    if isempty(value), value = tokens{1}{2}; end

    options.(name) = value;
  end

  fclose(fid);
end
