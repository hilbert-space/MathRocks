function string = toString(object, varargin)
  if numel(object) == 1 && ...
    (ismethod(object, 'toString') || isprop(object, 'toString'))

    string = object.toString;
    return;
  end

  switch class(object)
  case 'char'
    string = object;
  case 'double'
    if isempty(varargin)
      format = '%.2f';
    else
      format = varargin{1};
    end
    string = arrayToString(object, format);
  case { 'uint8', 'uint16', 'uint32' }
    if isempty(varargin)
      format = '%d';
    else
      format = varargin{1};
    end
    string = arrayToString(object, format);
  case 'cell'
    string = cellToString(object, varargin{:});
  otherwise
    error('The object class is not yet supported.');
  end
end

function string = arrayToString(object, format)
  object = object(:);
  count = numel(object);

  switch count
  case 0
    string = '[]';
  case 1
    string = sprintf(format, object(1));
  case 2
    string = sprintf([ '[ ', format, ', ', format, ' ]' ], ...
      object(1), object(2));
  otherwise
    delta = diff(object);
    if length(unique(delta)) == 1
      if delta(1) == 1
        string = sprintf([ format, ':', format ], ...
          object(1), object(end));
      else
        string = sprintf([ format, ':', format, ':', format ], ...
          object(1), delta(1), object(end));
      end
    else
      string = sprintf(format, object(1));
      for i = 2:count
        string = sprintf([ '%s, ', format ], string, object(i));
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
