function output = request(varargin)
  options = Options(varargin{:});

  prompt = options.get('prompt', '');

  type = options.get('type', '');

  switch type
  case 'char'
    output = input(prompt, 's');
  otherwise
    output = input(prompt);
  end

  if isempty(output) && options.has('default')
    if isa(options.default, 'function_handle')
      output = options.default();
    else
      output = options.default;
    end
  end

  if options.get('upper', false)
    output = upper(output);
  end

  if ~isempty(type)
    output = feval(type, output);
  end
end
