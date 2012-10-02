function values = evaluate(this, newNodes)
  nodes = this.evaluationNodes;
  intervals = this.evaluationIntervals;
  surpluses = this.surpluses;

  nodeCount = size(nodes, 1);

  newNodeCount = size(newNodes, 1);
  values = zeros(newNodeCount, 1);

  for i = 1:newNodeCount
    delta = abs(repmat(newNodes(i, :), nodeCount, 1) - nodes);
    mask = delta < 1.0 ./ intervals;
    basis = [ 1; prod((1.0 - intervals .* delta) .* mask, 2) ];
    values(i) = sum(surpluses .* basis);
  end
end
