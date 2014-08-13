function [nameFormat, valueFormat] = format(names)
  width = -Inf;
  for i = 1:length(names)
    width = max(width, length(names{i}));
  end
  width = width + 2;

  nameFormat = ['%', num2str(width), 's'];
  valueFormat = ['%', num2str(width), 'g'];
end
