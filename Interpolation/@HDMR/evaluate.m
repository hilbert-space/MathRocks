function values = evaluate(this, newNodes)
  assert(all(all(newNodes >= 0)) && all(all(newNodes <= 1)));

  inputDimension = this.inputDimension;
  outputDimension = this.outputDimension;

  offset = this.offset;
  interpolants = this.interpolants;

  newNodeCount = size(newNodes, 1);
  interpolantCount = length(interpolants);

  assert(length(offset) == outputDimension);

  values = repmat(offset, newNodeCount, 1);

  for i = 1:interpolantCount
    values = values + interpolants(i).evaluate(newNodes(:, i));
  end
end
