function [path, file, name, line] = trace(offset)
  if nargin == 0, offset = 1; end

  index = 1 + offset;

  stack = dbstack('-completenames');
  if length(stack) < index
    error('The depth of the stack is not sufficient.');
  else
    [path, name, extension] = fileparts(stack(index).file);
    file = [name, extension];
    name = stack(index).name;
    line = stack(index).line;
  end
end
