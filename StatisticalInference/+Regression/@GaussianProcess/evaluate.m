function [ mean, variance ] = evaluate(this, newNodes)
  if nargout > 1, error('Variance is not supported yet.'); end

  nodes = this.nodes;

  nodeCount = size(nodes, 1);
  newNodeCount = size(newNodes, 1);

  %
  % Normalize the new nodes.
  %
  newNodes = (newNodes - repmat(this.nodeMean, newNodeCount, 1)) ./ ...
    repmat(this.nodeDeviation, newNodeCount, 1);

  [ I, J ] = meshgrid(1:newNodeCount, 1:nodeCount);
  I = I'; J = J';

  K = this.kernel(newNodes(I(:), :)', nodes(J(:), :)');
  K = reshape(K, [ newNodeCount, nodeCount ]);

  mean = K * this.mapping;

  %
  % 'Denormalize' the result.
  %
  mean = repmat(this.responseMean, newNodeCount, 1) + mean .* ...
    repmat(this.responseDeviation, newNodeCount, 1);
end
