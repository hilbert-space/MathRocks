function value = computeWavelets(this, index, node, newNode)
  count = this.countNodes(index);
  delta = abs(newNode - node);
  if delta < 1 / (count - 1)
    value = 1 - (count - 1) * delta;
  else
    value = 0;
  end
end
