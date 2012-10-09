function output = read(varargin)
  options = Options(varargin{:});

  if options.get('char', false)
    output = input('', 's');
  else
    output = input('');
  end

  if isempty(output)
    output = options.default;
  end

  if options.get('upper', false)
    output = upper(output);
  end
end
