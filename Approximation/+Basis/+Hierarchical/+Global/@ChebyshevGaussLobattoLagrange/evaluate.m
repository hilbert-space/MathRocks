function values = evaluate(this, points, indexes, surpluses)
  [ pointCount, dimensionCount ] = size(points);
  outputCount = size(surpluses, 2);

  counts = prod(reshape(this.Ni(indexes), size(indexes)), 2);
  offsets = cumsum([ 0; counts(1:(end - 1)) ]);

  values = zeros(pointCount, outputCount);

  active = false(pointCount, dimensionCount);
  tensor = zeros(pointCount, dimensionCount, 'uint8');
  coefficients = cell(dimensionCount, 1);
  enumerator = zeros(dimensionCount, outputCount);

  for i = 1:size(indexes, 1)
    range = (offsets(i) + 1):(offsets(i) + counts(i));
    orders = this.Ni(indexes(i, :)) - 1;
    nodes = this.Yij(indexes(i ,:));

    active(:) = false;
    tensor(:) = 0;

    for k = 1:dimensionCount
      if orders(k) == 0, continue; end
      [ M, I ] = ismember(points(:, k), nodes{k});
      tensor(M, k) = I(M) - 1;
      active(~M, k) = true;
    end

    I = all(~active, 2);
    if any(I)
      values(I, :) = values(I, :) + surpluses(range( ...
        Utils.indexTensor(tensor(I, :) + 1, orders + 1)), :);
      I = find(~I);
      leftPointCount = length(I);
      if leftPointCount == 0, continue; end
    else
      I = 1:pointCount;
      leftPointCount = pointCount;
    end

    positions = ones(leftPointCount, 1, 'uint32');
    for k = 1:dimensionCount
      positions = positions + (uint32(tensor(I, k) + 1) - 1) * ...
        prod(uint32(orders(1:(k - 1)) + 1));
    end

    for j = 1:leftPointCount
      index = tensor(I(j), :);
      point = points(I(j), :);
      dimensions = find(active(I(j), :));
      leftDimensionCount = length(dimensions);

      denominator = 1;
      for k = dimensions
        coefficients{k} = transpose([ 0.5, ones(1, orders(k) - 1), 0.5 ] .* ...
          (-1).^double(0:orders(k)) ./ (point(k) - nodes{k}));
        denominator = denominator * sum(coefficients{k});
      end

      done = leftDimensionCount == 1;

      cursor = positions(j);
      step = uint32(index(dimensions(1)) + 1) * ...
        prod(uint32(orders(1:(dimensions(1) - 1)) + 1));

      enumerator(:) = 0;
      while true
        k = dimensions(1);
        if outputCount == 1
          enumerator(k, :) = enumerator(k, :) + sum( ...
            surpluses(range(cursor + step * (0:orders(k))), :) .* ...
            coefficients{k});
        else
          enumerator(k, :) = enumerator(k, :) + sum(bsxfun(@times, ...
            surpluses(range(cursor + step * (0:orders(k))), :), ...
            coefficients{k}), 1);
        end
        index(k) = orders(k);
        cursor = cursor + step * (orders(k) + 1);
        for l = 2:leftDimensionCount
          k = dimensions(l);
          enumerator(k, :) = enumerator(k, :) + ...
            coefficients{k}(index(k) + 1) * enumerator(dimensions(l - 1), :);
          enumerator(dimensions(l - 1), :) = 0;
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

      values(I(j), :) = values(I(j), :) + ...
        enumerator(dimensions(end), :) / denominator;
    end
  end
end
