function [ mean, variance ] = evaluate(this, newNodes)
  %
  % Reference:
  %
  % C. Rasmussen and C. Williams. Gaussian Processes for Machine Learning,
  % The MIT press, 2006, pp. 15--16.
  %

  kernel = this.kernel;
  parameters = this.parameters;
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

  Kmix = this.kernel(newNodes(I(:), :)', nodes(J(:), :)', parameters);
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
  Knew = this.kernel(newNodes(I(:, 1), :)', newNodes(I(:, 2), :)', parameters);
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
