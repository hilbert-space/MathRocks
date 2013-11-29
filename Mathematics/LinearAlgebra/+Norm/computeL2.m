function norm = computeL2(data, dimension)
  if nargin < 3, data = data(:); dimension = 1; end
  norm = sqrt(sum(data.^2, dimension));
end
