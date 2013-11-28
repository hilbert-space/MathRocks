function string = capitalize(string)
  string = regexprep(string, '([A-Z])',' ${lower($1)}');
  string = regexprep(string, '^\s*([a-z])', '${upper($1)}');
end
