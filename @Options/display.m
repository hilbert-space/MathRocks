function display(this, title, offset)
  if nargin > 1 && ~isempty(title), fprintf('%s:\n', title); end
  if nargin < 3, offset = 2; end

  names = fieldnames(this);
  nameCount = length(names);
  displayNames = names;

  nameWidth = -Inf;
  for i = 1:nameCount
    displayNames{i} = String.capitalize(displayNames{i});
    nameWidth = max(nameWidth, length(displayNames{i}));
  end

  nameOffset = sprintf([ '%', num2str(offset), 's' ], '');

  for i = 1:nameCount
    value = this.(names{i});

    fprintf([ nameOffset, '%-', num2str(nameWidth), 's: ' ], ...
      displayNames{i});

    if isa(value, 'Options')
      fprintf('\n');
      display(value, [], offset + 2);
    else
      fprintf('%s\n', String(value));
    end
  end
end
