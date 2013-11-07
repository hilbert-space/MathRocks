function norm = computeInf(data, dimension)
  if nargin < 3, data = data(:); dimension = 1; end
  norm = max(data, [], dimension);
end
