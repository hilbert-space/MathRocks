function nodesND = tensor(nodes1D)
  dimensionCount = length(nodes1D);
  grid = cell(1, dimensionCount);
  [ grid{:} ] = ndgrid(nodes1D{:});
  nodesND = zeros(numel(grid{1}), dimensionCount);
  for i = 1:dimensionCount, nodesND(:, i) = grid{i}(:); end
end
