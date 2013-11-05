function [ functions, values ] = construct(~, options)
  kernel = options.kernel;
  domainBoundary = options.domainBoundary;
  dimensionCount = options.get('dimensionCount', NaN);

  D = domain([ -domainBoundary, domainBoundary ]);
  F = fred(kernel, D);

  if isnan(dimensionCount)
    reductionThreshold = options.reductionThreshold;

    totalVariance = sum(chebfun(@(x) kernel(x, x), D));

    dimensionCount = 10;
    maxDimensionCount = 100;
    while true
      [ V, L ] = eigs(F, dimensionCount, 'lm');
      L = diag(L);

      C = cumsum(L) / totalVariance;
      I = find(C > reductionThreshold);

      if isempty(I)
        if dimensionCount == maxDimensionCount
          warning('KarhunenLoeve: failed to gain %.2f%% of variance with %d dimensions.', ...
            100 * reductionThreshold, maxDimensionCount);
          break;
        end
        dimensionCount = min(dimensionCount + 10, maxDimensionCount);
      else
        dimensionCount = I(1);
        break;
      end
    end
  else
    [ V, L ] = eigs(F, dimensionCount, 'lm');
    L = diag(L);
  end

  functions = cell(dimensionCount, 1);
  for i = 1:dimensionCount
    functions{i} = V(:, i);
  end
  values = L(1:dimensionCount);
end
