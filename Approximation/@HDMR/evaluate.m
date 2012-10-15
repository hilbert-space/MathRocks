function values = evaluate(this, newNodes)
  assert(all(all(newNodes >= 0)) && all(all(newNodes <= 1)));

  interpolants = this.interpolants;
  inputDimension = this.inputDimension;

  assert(inputDimension == size(newNodes, 2));

  newNodeCount = size(newNodes, 1);

  values = repmat(this.offset, newNodeCount, 1);

  keys = interpolants.keys;
  for i = 1:length(keys)
    key = keys{i};
    index = uint16(key);
    values = values + interpolants(key).evaluate(newNodes(:, index));
  end
end
