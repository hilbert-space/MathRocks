function [ functions, values ] = construct(~, options)
  kernel = options.kernel;
  domainBoundary = options.domainBoundary;
  dimensionCount = options.get('dimensionCount', NaN);

  F = fred(kernel, domain([ -domainBoundary, domainBoundary ]));

  if isnan(dimensionCount)
    dimensionCount = 10;
    maxDimension = 100;
    reductionThreshold = options.reductionThreshold;

    %
    % Estimate all the eigenvalues based on a few of them.
    %
    L = eigs(F, dimensionCount, 'lm');
    alpha = [ ones(dimensionCount, 1), - (1:dimensionCount)' ] \ log(sqrt(L));
    L = exp(alpha(1)) .* (exp(alpha(2)) .^ (-(1:maxDimension)'));
    dimensionCount = Utils.chooseSignificant(L, reductionThreshold);

    [ V, L ] = eigs(F, dimensionCount, 'lm');
    [ dimensionCount, values ] = ...
      Utils.chooseSignificant(diag(L), reductionThreshold);
  else
    [ V, L ] = eigs(F, dimensionCount, 'lm');
    values = diag(L);
  end

  functions = cell(dimensionCount, 1);
  for i = 1:dimensionCount
    functions{i} = V(:, i);
  end
end
