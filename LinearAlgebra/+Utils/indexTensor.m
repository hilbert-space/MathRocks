function I = indexTensor(indexes, dimensions)
  I = ones(size(indexes, 1), 1, 'uint32');
  dimensionCount = length(dimensions);
  for i = dimensionCount:-1:1
    I = I + (uint32(indexes(:, i)) - 1) * ...
      prod(uint32(dimensions(1:(i - 1))));
  end
end
