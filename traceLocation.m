function [ path, file, name, line ] = traceLocation()
  stack = dbstack('-completenames');
  if length(stack) < 2
    error('Is not supposed to be called from the console.');
  else
    chunks = regexp(stack(2).file, '^(.*)/([^/]+)$', 'tokens');
    path = chunks{1}{1};
    file = chunks{1}{2};
    name = stack(2).name;
    line = stack(2).line;
  end
end
