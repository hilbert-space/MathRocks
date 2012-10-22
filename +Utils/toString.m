function string = toString(object)
  switch class(object)
  case 'char'
    string = object;
  case 'double'
    string = arrayToString(object, '%2.f');
  case { 'uint8', 'uint16', 'uint32' }
    string = arrayToString(object, '%d');
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
  if count == 0
    string = '[]';
    return;
  end

  delta = diff(object);
  if length(unique(delta)) == 1
    if delta(1) == 1.0
      string = sprintf([ format, ':', format ], ...
        object(1), object(end));
    else
      string = sprintf([ format, ':', format, ':', format ], ...
        object(1), delta(1), object(end));
    end
    return;
  end

  string = sprintf(format, object(1));

  if count == 1, return; end

  for i = 2:count
    string = sprintf([ '%s, ', format ], string, object(i));
  end
  string = [ '[ ', string, ' ]' ];
end
