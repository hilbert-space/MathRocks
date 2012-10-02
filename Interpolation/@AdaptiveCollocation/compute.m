function result = compute(this, newNodes)
  dimension = this.dimension;

  nodes = this.nodes;
  weights = this.weights;
  index = this.index;
  map = this.map;

  points = length(weights);
  newPoints = size(newNodes, 1);

  one = repmat(permute(nodes, [ 3, 1, 2 ]), [ newPoints, 1, 1 ]);
  two = repmat(permute(newNodes, [ 1, 3, 2 ]), [ 1, points, 1 ]);

  delta = abs(one - two);

  I = find(index > 1);

  counts = ones(size(index));
  counts(I) = 2.^(index(I) - 1) + 1;
  counts = counts(map, :);
  counts = repmat(permute(counts, [ 3, 1, 2 ]), [ newPoints, 1, 1 ]);

  one = repmat(weights.', [ newPoints, 1 ]);
  two = prod((1 - (counts - 1) .* delta) .* (delta < 1 ./ (counts - 1)), 3);

  result = sum(one .* two, 2);
end
