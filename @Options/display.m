function display(this, title, level)
  if nargin < 2, title = class(this); end
  if nargin < 3, level = 1; end

  if ~isempty(title)
    fprintf('%s:\n', title);
  end

  nameWidth = 20;
  namePrefix = '  ';
  for i = 2:level
    nameWidth = max(10, nameWidth - 2);
    namePrefix = [ namePrefix, '  ' ];
  end

  names = properties(this);

  for i = 1:length(names)
    name = names{i};
    value = this.(name);

    fprintf([ namePrefix, '%-', num2str(nameWidth), 's: ' ], name);
    switch class(value)
    case 'Options'
      fprintf('\n');
      display(value, [], level + 1);
    case { 'int8', 'int16', 'int32', 'uint8', 'uint16', 'uint32', 'double', 'logical' }
      if length(value) ~= 1
        fprintf('%s\n', Utils.toString(value));
      else
        fprintf('%s\n', num2str(value));
      end
    case 'char'
      fprintf('%s\n', value);
    otherwise
      fprintf('<...>\n');
    end
  end
end
