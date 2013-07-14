function [ nodes, weights ] = constructAdaptive(this, options)
  dimensionCount = options.dimensionCount;

  [ nodes, weights ] = this.constructSparse(options);

  sparseNodeCount = size(nodes, 1);
  tensorNodeCount = options.order^dimensionCount;

  if sparseNodeCount >= tensorNodeCount
    [ nodes, weights ] = this.constructTensor(options);
    assert(size(nodes, 1) == tensorNodeCount);
  end
end
