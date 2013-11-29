function result = evaluate(this, points, indexes, surpluses, offsets, range)
  if ~exist('range', 'var'), range = 1:size(indexes, 1); end

  [ pointCount, dimensionCount ] = size(points);
  outputCount = size(surpluses, 2);

  result = zeros(pointCount, outputCount);

  for i = range
    active = indexes(i, :) > 1;

    if all(~active)
      result = result + ...
        repmat(surpluses(offsets(i) + 1, :), pointCount, 1);
      continue;
    end

    nodes = this.computeNodes(indexes(i, active));
    nodeCount = size(nodes, 1);

    range = (offsets(i) + 1):(offsets(i) + nodeCount); % overwrite

    limits = this.limits(indexes(i, active));
    orders = double(this.orders(indexes(i, active)));

    if dimensionCount == 1
      for j = 1:pointCount
        D = abs(nodes - points(j));
        J = D < limits;
        result(j, :) = result(j, :) + ...
          sum(surpluses(range(J), :) * (1 - (orders - 1) * D(J, :)), 1);
      end
    else
      for j = 1:pointCount
        D = abs(bsxfun(@minus, nodes, points(j, active)));
        J = all(bsxfun(@lt, D, limits), 2);
        result(j, :) = result(j, :) + ...
          sum(bsxfun(@times, surpluses(range(J), :), ...
            prod(1 - bsxfun(@times, D(J, :), orders - 1), 2)), 1);
      end
    end
  end
end
