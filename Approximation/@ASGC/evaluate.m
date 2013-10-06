function values = evaluate(this, output, newNodes)
  newNodeCount = size(newNodes, 1);

  values = zeros(newNodeCount, output.outputCount);

  surpluses = output.surpluses;
  base = this.basis.evaluate(newNodes, output.levels, output.orders);

  for i = 1:newNodeCount
    values(i, :) = sum(bsxfun(@times, surpluses, base(:, i)), 1);
  end
end
