function [ path, file, name, line ] = trace()
  stack = dbstack('-completenames');
  if length(stack) < 2
    error('Is not supposed to be called from the console.');
  else
    [ path, name, extension ] = fileparts(stack(2).file);
    file = [ name, extension ];
    name = stack(2).name;
    line = stack(2).line;
  end
end
