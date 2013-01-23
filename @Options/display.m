function display(this, title, level)
  if nargin > 1 && ~isempty(title)
    fprintf('%s:\n', title);
  end

  nameWidth = 20;
  namePrefix = '  ';

  if nargin > 2
    for i = 2:level
      nameWidth = max(10, nameWidth - 2);
      namePrefix = [ namePrefix, '  ' ];
    end
  else
    level = 1;
  end

  names = properties(this);

  for i = 1:length(names)
    name = names{i};
    value = this.(name);

    fprintf([ namePrefix, '%-', num2str(nameWidth), 's: ' ], name);

    if isa(value, 'Options')
      fprintf('\n');
      display(value, [], level + 1);
    else
      fprintf('%s\n', Utils.toString(value));
    end
  end
end
