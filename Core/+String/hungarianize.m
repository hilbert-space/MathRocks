function string = hungarianize(string)
  string = regexprep(string, '[-\s](\w)', '${upper($1)}');
  string = regexprep(string, '^\s*([A-Z])', '${lower($1)}');
end
