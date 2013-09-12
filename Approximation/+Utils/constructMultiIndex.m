function index = constructMultiIndex(dimension, maxOrder, weights, method)
  if nargin < 3 || isempty(weights), weights = ones(1, dimension); end
  if nargin < 4, method = 'totalOrder'; end

  assert(dimension > 0, 'The dimension is invalid.');
  assert(maxOrder >= 0, 'The order is invalid.');
  assert(nnz(weights < 0 | weights > 1) == 0, 'The weights are invalid.');

  switch lower(method)
  case 'tensorproduct'
    index = constructTensorProduct(dimension, maxOrder);
    weights = repmat(weights, size(index, 1), 1);
    I = max(index .* weights, [], 2) <= maxOrder;
  case 'totalorder'
    valid = @(index) sum(index .* weights) <= maxOrder;
    index = constructTotalOrder(dimension, maxOrder);
    weights = repmat(weights, size(index, 1), 1);
    I = sum(index .* weights, 2) <= maxOrder;
  otherwise
    error('The construction method is unknown.');
  end
end

function index = constructTensorProduct(dimension, maxOrder)
  vecs = {};

  for i = 1:dimension
    vecs{end + 1} = 0:maxOrder;
  end

  [ vecs{:} ] = ndgrid(vecs{:});
  index = reshape(cat(dimension + 1, vecs{:}), [], dimension);
end

function Index = constructTotalOrder(dimension, maxOrder)
  Index = zeros(0, dimension);

  index = zeros(1, dimension);

  %
  % Add the zeroth chaos.
  %
  Index(end + 1, :) = index;
  done = 1;

  if maxOrder == 0, return; end

  %
  % Add the first chaos.
  %
  for i = 1:dimension
    index(i) = 1;
    Index(end + 1, :) = index;
    done = done + 1;
    index(i) = 0;
  end
  if maxOrder == 1, return; end

  p = zeros(maxOrder, dimension);
  p(1, :) = 1;

  for order = 2:maxOrder
    fixedDone = done;

    for i = 1:dimension
      p(order, i) = sum(p(order - 1, i:dimension));
    end

    for i = 1:dimension
      for j = (fixedDone - p(order, i)):(fixedDone - 1)
        index = Index(j + 1, :);
        index(i) = index(i) + 1;

        Index(end + 1, :) = index;
        done = done + 1;
      end
    end
  end
end
