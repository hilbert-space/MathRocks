function display(this, title, level)
  if nargin > 1 && ~isempty(title)
    fprintf('%s:\n', title);
  end

  names = properties(this);
  nameCount = length(names);
  displayNames = names;

  nameWidth = -Inf;
  for i = 1:nameCount
    displayNames{i} = regexprep(displayNames{i}, ...
      '([A-Z])',' ${lower($1)}');
    displayNames{i} = regexprep(displayNames{i}, ...
      '(^\s*[a-z])','${upper($1)}');
    nameWidth = max(nameWidth, length(displayNames{i}));
  end
  nameWidth = nameWidth + 1;

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
    value = this.(names{i});

    fprintf([ namePrefix, '%-', num2str(nameWidth), 's: ' ], ...
      displayNames{i});

    if isa(value, 'Options')
      fprintf('\n');
      display(value, [], level + 1);
    else
      fprintf('%s\n', Utils.toString(value));
    end
  end
end
