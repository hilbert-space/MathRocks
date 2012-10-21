function output = read(varargin)
  options = Options(varargin{:});

  prompt = options.get('prompt', '');

  if options.get('char', false)
    output = input(prompt, 's');
  else
    output = input(prompt);
  end

  if isempty(output) && options.has('default')
    output = options.default;
  end

  if options.get('upper', false)
    output = upper(output);
  end

  if options.has('convert')
    output = feval(options.convert, output);
  end
end
