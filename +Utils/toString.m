function string = toString(object, format)
  switch class(object)
  case 'char'
    string = object;
  case 'double'
    if nargin < 2, format = '%.2f'; end
    string = arrayToString(object, format);
  case { 'uint8', 'uint16', 'uint32' }
    if nargin < 2, format = '%d'; end
    string = arrayToString(object, format);
  otherwise
    error('The object class is not yet supported.');
  end
end

function string = arrayToString(object, format)
  [ rows, cols ] = size(object);

  if ~(rows == 1 || cols == 1)
    error('Matrices are not supported yet.');
  end

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
