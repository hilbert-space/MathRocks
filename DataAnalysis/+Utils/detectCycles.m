function [ index, fractions, extremumIndex ] = detectCycles(data, tolerance)
  if nargin < 2, tolerance = 0; end

  assert(ismatrix(data));
  componentCount = size(data, 1);

  index = cell(1, componentCount);
  fractions = cell(1, componentCount);
  extremumIndex = cell(1, componentCount);

  for i = 1:componentCount
    extremumIndex{i} = Utils.detectExtrema(data(i, :), tolerance);
    [ J, fractions{i} ] = Utils.countCycles(data(i, extremumIndex{i}));
    index{i} = extremumIndex{i}(J);
  end
end