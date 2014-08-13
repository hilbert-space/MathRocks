function shape = pick(i)
  if nargin == 0, i = randi(100); end

  shapes = { 'o', 's', '*', 'd', '+', '^', 'v', '>', '<', 'p', 'h' };

  shape = shapes{mod(i - 1, length(shapes)) + 1};
end
