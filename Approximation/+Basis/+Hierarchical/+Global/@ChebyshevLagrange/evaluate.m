function result = evaluate(this, points, indexes, surpluses, offsets, range)
  %
  % Evaluation of multidimensional Lagrange polynomials using
  % the barycentric formula on Chebyshev-Gauss-Lobatto quadratureNodes.
  %
  % Reference:
  %
  % W. A. Klimke. Uncertainty modeling using fuzzy arithmetic and
  % sparse grids. University of Stuttgart. 2006.
  %

  epsilon = sqrt(eps);

  if ~exist('range', 'var'), range = 1:size(indexes, 1); end

  [ pointCount, dimensionCount ] = size(points);
  outputCount = size(surpluses, 2);

  result = zeros(pointCount, outputCount);

  present = false(pointCount, 1);
  active = false(pointCount, dimensionCount);
  nonzero = false(pointCount, 1);

  iterators = zeros(pointCount, dimensionCount, 'uint32');
  numerator = zeros(dimensionCount, outputCount);

  coefficients = cell(dimensionCount, 1);

  for i = range
    index = uint32(indexes(i, :));

    if all(index == 1)
      %
      % A special case: there is only one multidimensional node; thus,
      % the order of the Lagrange polynomial is zero, and its value is
      % just the corresponding surplus itself.
      %
      result = result + repmat(surpluses(offsets(i) + 1, :), pointCount, 1);
      continue;
    end

    quadratureNodes = this.quadratureNodes(indexes(i, :));
    barycentricWeights = this.barycentricWeights(indexes(i, :));
    orders = uint32(this.counts(indexes(i, :)) - 1);

    active(:) = false;
    nonzero(:) = true;

    iterators(:) = 0;

    for k = 1:dimensionCount
      %
      % The same comment as before: the first level correspond to
      % zero-order Lagrange polynomials, and, for a zero-order
      % polynomial, we do not need any complex interpolation: the
      % polynomial in the kth dimension is one.
      %
      if index(k) == 1, continue; end

      %
      % The following two categories of points require special treatments:
      %
      % (a) the points that belong to the hierarchical set of points and
      % (b) the points that are present in the nodal set of points but not
      % in the hierarchical one.
      %
      % In the first case, the one-dimensional Lagrange polynomial in
      % the kth dimension is one.
      %
      % In the second case, the one-dimensional Lagrange polynomial in
      % the kth dimension is zero, and, therefore, the multidimensional
      % polynomial is also zero.
      %

      %
      % The task now is to check whether the points, with respect to the kth
      % dimension, are among the nodes of the corresponding one-dimensional
      % quadrature. Since the quadrature nodes are sorted, the membership
      % check can be simplified as follows.
      %
      % NOTE: Is it worth caching the result of this operation as it is
      % being repeated several times with the same arguments?
      %
      I = builtin('_ismemberfirst', round(points(:, k) / epsilon), ...
        round(quadratureNodes{k} / epsilon));
      present(:) = I > 0;

      if nnz(present) == 0
        active(:, k) = true;
        continue;
      end

      active(~present, k) = true;

      if index(k) == 2
        %
        % In this case, the second category contains only one node,
        % which is the middle node equal to 0.5.
        %
        nonzero(present & (I == 2)) = false;

        %
        % Convert the nodal-based ordering of the nodes to the
        % hierarchical one and start counting from zero.
        %
        % 1 -> 0 -> 0
        % 3 -> 2 -> 1
        %
        iterators(present & nonzero, k) = (I(present & nonzero) - 1) / 2;
      else % level > 2
        %
        % In this case, the second category contains the nodes whose
        % indexes (starting from one) are odd numbers.
        %
        nonzero(present & (mod(I, 2) == 1)) = false;

        %
        % Convert the nodal-based ordering of the nodes to the
        % hierarchical one and start counting from zero.
        %
        % 2 -> 1 -> 0
        % 4 -> 2 -> 1
        % 6 -> 3 -> 2
        % ...
        %
        iterators(present & nonzero, k) = I(present & nonzero) / 2 - 1;
      end

      if nnz(nonzero) == 0, break; end
    end

    %
    % Find the nodes whose multidimensional Lagrange polynomials are
    % equal to one. This event occurs when each component of a node
    % either is in the corresponding one-dimensional quadrature or
    % its corresponding level is one. For such nodes, the corresponding
    % surpluses can be added without any extra coefficients.
    %
    I = all(~active, 2) & nonzero;
    if any(I)
      result(I, :) = result(I, :) + surpluses(offsets(i) + ...
        Utils.indexTensor(iterators(I, :) + 1, orders + 1), :);
    end

    %
    % Find the nodes that require interpolation: they are not in
    % the multidimensional grid, and the corresponding polynomials
    % are nonzero.
    %
    I = find(any(active, 2) & nonzero);
    leftPointCount = length(I);

    if leftPointCount == 0, continue; end

    %
    % Precompute the starting positions of the surpluses and the
    % corresponding steps with respect to the first active dimension.
    %
    [ J, K ] = find(active(I, :));
    K = accumarray(J, K, [], @min);
    J = [ 1, cumprod(orders(1:(end - 1)) + 1) ];

    positions = offsets(i) + 1 + ...
      sum(bsxfun(@times, iterators(I, :), J), 2, 'native');
    steps = J(K);

    for j = 1:leftPointCount
      iterator = iterators(I(j), :);
      point = points(I(j), :);
      dimensions = find(active(I(j), :));
      leftDimensionCount = length(dimensions);

      %
      % First, we compute the denominator.
      %
      denominator = 1;

      for k = dimensions
        coefficients{k} = transpose(barycentricWeights{k} ./ ...
          (point(k) - quadratureNodes{k}));
        denominator = denominator * sum(coefficients{k});

        %
        % Preserve only the coefficients that are relevant to
        % the hierarchical level.
        %
        if index(k) == 2
          coefficients{k} = coefficients{k}([ 1, 3 ]);
        else % level > 2 as it cannot be one at this point
          coefficients{k} = coefficients{k}((1:2^(index(k) - 2)) * 2);
        end
      end

      %
      % Then, we compute the numerator.
      %
      numerator(:) = 0;

      position = positions(j);
      step = steps(j);

      done = leftDimensionCount == 1;

      while true
        k = dimensions(1);
        if outputCount == 1
          numerator(k) = numerator(k) + sum( ...
            surpluses(position + step * (0:orders(k))) .* ...
            coefficients{k});
        else
          numerator(k, :) = numerator(k, :) + sum(bsxfun(@times, ...
            surpluses(position + step * (0:orders(k)), :), ...
            coefficients{k}), 1);
        end
        iterator(k) = orders(k);
        position = position + step * (orders(k) + 1);
        for l = 2:leftDimensionCount
          k = dimensions(l);
          numerator(k, :) = numerator(k, :) + ...
            coefficients{k}(iterator(k) + 1) * ...
            numerator(dimensions(l - 1), :);
          numerator(dimensions(l - 1), :) = 0;
          if iterator(k) < orders(k)
            iterator(k) = iterator(k) + 1;
            break;
          elseif l < leftDimensionCount
            iterator(k) = 0;
          else
            done = true;
          end
        end
        if done, break; end
      end

      result(I(j), :) = result(I(j), :) + ...
        numerator(dimensions(end), :) / denominator;
    end
  end
end
