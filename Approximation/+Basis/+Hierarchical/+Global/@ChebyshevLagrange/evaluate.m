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

  if ~exist('range', 'var'), range = 1:size(indexes, 1); end

  [ pointCount, dimensionCount ] = size(points);
  outputCount = size(surpluses, 2);

  result = zeros(pointCount, outputCount);

  active = false(pointCount, dimensionCount);
  iterator = zeros(pointCount, dimensionCount, 'uint8');
  coefficients = cell(dimensionCount, 1);
  numerator = zeros(dimensionCount, outputCount);

  for i = range
    quadratureNodes = this.quadratureNodes(indexes(i, :));
    barycentricWeights = this.barycentricWeights(indexes(i, :));

    orders = this.counts(indexes(i, :)) - 1;
    nodes = this.nodes(indexes(i, :));

    active(:) = false;
    iterator(:) = 0;

    for k = 1:dimensionCount
      if orders(k) == 0, continue; end
      [ M, I ] = ismember(points(:, k), nodes{k});
      iterator(M, k) = I(M) - 1;
      active(~M, k) = true;
    end

    I = all(~active, 2);
    if any(I)
      result(I, :) = result(I, :) + surpluses(offsets(i) + ...
        Utils.indexTensor(iterator(I, :) + 1, orders + 1), :);
      I = find(~I);
      leftPointCount = length(I);
      if leftPointCount == 0, continue; end
    else
      I = 1:pointCount;
      leftPointCount = pointCount;
    end

    positions = offsets(i) + ones(leftPointCount, 1, 'uint32');
    for k = 1:dimensionCount
      positions = positions + (uint32(iterator(I, k) + 1) - 1) * ...
        prod(uint32(orders(1:(k - 1)) + 1));
    end

    for j = 1:leftPointCount
      index = iterator(I(j), :);
      point = points(I(j), :);
      dimensions = find(active(I(j), :));
      leftDimensionCount = length(dimensions);

      denominator = 1;
      for k = dimensions
        coefficients{k} = transpose(barycentricWeights{k} ./ ...
          (point(k) - quadratureNodes{k}));
        denominator = denominator * sum(coefficients{k});

        %
        % Preserve only the coefficients that are relevant to
        % the hierarchical level.
        %
        switch indexes(i, k)
        case 1
        case 2
          coefficients{k} = coefficients{k}([ 1, 3 ]);
        otherwise
          coefficients{k} = coefficients{k}( ...
            (1:2^(uint32(indexes(i, k)) - 2)) * 2);
        end
      end

      done = leftDimensionCount == 1;
      cursor = positions(j);

      numerator(:) = 0;
      while true
        k = dimensions(1);
        if outputCount == 1
          numerator(k, :) = numerator(k, :) + sum( ...
            surpluses(cursor + (0:orders(k)), :) .* ...
            coefficients{k});
        else
          numerator(k, :) = numerator(k, :) + sum(bsxfun(@times, ...
            surpluses(cursor + (0:orders(k)), :), ...
            coefficients{k}), 1);
        end
        index(k) = orders(k);
        cursor = cursor + orders(k) + 1;
        for l = 2:leftDimensionCount
          k = dimensions(l);
          numerator(k, :) = numerator(k, :) + ...
            coefficients{k}(index(k) + 1) * numerator(dimensions(l - 1), :);
          numerator(dimensions(l - 1), :) = 0;
          if index(k) < orders(k)
            index(k) = index(k) + 1;
            break;
          elseif l < leftDimensionCount
            index(k) = 0;
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
