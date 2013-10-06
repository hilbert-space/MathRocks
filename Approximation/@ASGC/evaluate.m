function values = evaluate(this, output, newNodes)
  newNodeCount = size(newNodes, 1);

  values = zeros(newNodeCount, output.outputCount);

  surpluses = output.surpluses;
  base = this.basis.evaluate(output.levels, output.orders, newNodes);

  for i = 1:newNodeCount
    values(i, :) = sum(bsxfun(@times, surpluses, base(:, i)), 1);
  end
end
