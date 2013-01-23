function string = toString(object, varargin)
  if numel(object) == 1 && ...
    (ismethod(object, 'toString') || isprop(object, 'toString'))

    string = object.toString;
    return;
  end

  switch class(object)
  case 'char'
    string = object;
  case { 'int8', 'int16', 'int32', ...
    'uint8', 'uint16', 'uint32', 'double', 'logical' }
    string = arrayToString(object, varargin{:});
  case 'cell'
    string = cellToString(object, varargin{:});
  case 'function_handle'
    string = func2str(object);
  otherwise
    error('The object class is not yet supported.');
  end
end

function string = numberToString(object, varargin)
  if isempty(varargin)
    string = num2str(object);
  else
    string = sprintf(varargin{:}, object);
  end
end

function string = arrayToString(object, varargin)
  object = object(:);
  count = numel(object);

  switch count
  case 0
    string = '[]';
  case 1
    string = numberToString(object, varargin{:});
  case 2
    string = sprintf('[ %s, %s ]', ...
      numberToString(object(1), varargin{:}), ...
      numberToString(object(2), varargin{:}));
  otherwise
    delta = diff(object);
    if length(unique(delta)) == 1
      if delta(1) == 1
        string = sprintf('%s:%s', ...
          numberToString(object(1), varargin{:}), ...
          numberToString(object(end), varargin{:}));
      else
        string = sprintf('%s:%s:%s', ...
          numberToString(object(1), varargin{:}), ...
          numberToString(delta(1), varargin{:}), ...
          numberToString(object(end), varargin{:}));
      end
    else
      string = numberToString(object(1), varargin{:});
      for i = 2:count
        string = sprintf('%s, %s', string, ...
          numberToString(object(i), varargin{:}));
      end
      string = [ '[ ', string, ' ]' ];
    end
  end
end

function string = cellToString(object, varargin)
  [ rows, cols ] = size(object);

  if ~(rows == 1 || cols == 1)
    error('Matrices are not supported yet.');
  end

  count = numel(object);

  string = Utils.toString(object{1}, varargin{:});
  for i = 2:count
    string = sprintf('%s, %s', string, ...
      Utils.toString(object{i}, varargin{:}));
  end
  string = [ '{ ', string, ' }' ];
end
