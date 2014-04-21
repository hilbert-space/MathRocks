function [ index, extrema ] = detectExtrema(data, tolerance)
  assert(isvector(data));
  index = [ 1, find(diff(diff(data) > 0) ~= 0) + 1, numel(data) ];
  extrema = data(index);
end
