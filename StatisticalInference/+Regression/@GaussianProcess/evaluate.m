function [ mean, variance ] = evaluate(this, newNodes)
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

  Kmix = this.kernel(newNodes(I(:), :)', nodes(J(:), :)');
  Kmix = reshape(Kmix, [ newNodeCount, nodeCount ]);

  mean = Kmix * this.inverseKy;

  %
  % 'Denormalize' the result.
  %
  responseMean = repmat(this.responseMean, newNodeCount, 1);
  responseDeviation = repmat(this.responseDeviation, newNodeCount, 1);
  mean = responseMean + responseDeviation .* mean;

  if nargout == 1, return; end

  I = constructPairIndex(newNodeCount);
  Knew = this.kernel(newNodes(I(:, 1), :)', newNodes(I(:, 2), :)');
  Knew = constructSymmetricMatrix(Knew, I);

  %
  % The maximization tries to prevent the numerical noise.
  %
  variance = max(0, Knew - Kmix * this.inverseK * Kmix');

  %
  % Scaling as before.
  %
  variance = (responseDeviation * responseDeviation') .* variance;
end
