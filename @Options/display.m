function display(this, title, level)
  if nargin > 1 && ~isempty(title)
    fprintf('%s:\n', title);
  end

  names = properties(this);
  nameCount = length(names);

  nameWidth = -Inf;

  for i = 1:nameCount
    name = names{i};
    name = regexprep(name, '([A-Z])',' ${lower($1)}');
    name = regexprep(name, '(^\s*[a-z])','${upper($1)}');
    names{i} = name;
    nameWidth = max(nameWidth, length(name));
  end

  namePrefix = '  ';

  if nargin > 2
    for i = 2:level
      nameWidth = max(10, nameWidth - 2);
      namePrefix = [ namePrefix, '  ' ];
    end
  else
    level = 1;
  end

  for i = 1:nameCount
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
