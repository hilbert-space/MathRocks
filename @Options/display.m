function display(this, title, offset)
  if nargin > 1 && ~isempty(title), fprintf('%s:\n', title); end
  if nargin < 3, offset = 2; end

  names = sort(fieldnames(this));
  nameCount = length(names);
  displayNames = names;

  nameWidth = -Inf;
  for i = 1:nameCount
    displayNames{i} = regexprep(displayNames{i}, ...
      '([A-Z])',' ${lower($1)}');
    displayNames{i} = regexprep(displayNames{i}, ...
      '^\s*([a-z])', '${upper($1)}');
    nameWidth = max(nameWidth, length(displayNames{i}));
  end
  nameWidth = nameWidth + 1;

  nameOffset = sprintf([ '%', num2str(offset), 's' ], '');

  for i = 1:nameCount
    value = this.values(names{i});

    fprintf([ nameOffset, '%-', num2str(nameWidth), 's: ' ], ...
      displayNames{i});

    if isa(value, 'Options')
      fprintf('\n');
      display(value, [], offset + 2);
    else
      fprintf('%s\n', Utils.toString(value));
    end
  end
end
