function parameters = optimize(nodes, responses, kernel, ...
  startValues, lowerBound, upperBound, startCount)

  if ~exist('startCount', 'var'), startCount = 1; end

  nodeCount = size(nodes, 1);
  parameterCount = length(lowerBound);
  assert(length(upperBound) == parameterCount);

  I = constructPairIndex(nodeCount);

  nodes1 = nodes(I(:, 1), :)';
  nodes2 = nodes(I(:, 2), :)';

  function [ f, g ] = target(logParams)
    [ K, dK ] = kernel(nodes1, nodes2, exp(logParams));
    K = constructSymmetricMatrix(K, I);

    [ L, p ] = chol(K, 'lower');

    if p > 0
      f = NaN;
      g = NaN(1, parameterCount);
      return;
    end

    iK = L' \ (L \ eye(nodeCount));

    iKy = iK * responses;
    iKyiKyT = iKy * iKy';

    %
    % The function itself.
    %
    logp = -sum(diag(responses' * iKy)) / 2 - ...
      2 * sum(log(diag(L))) / 2 - nodeCount * log(2 * pi) / 2;
    f = -logp;

    %
    % The gradient of the function.
    %
    g = zeros(1, parameterCount);
    for j = 1:parameterCount
      dKj = constructSymmetricMatrix(dK(j, :), I);
      dlogp = trace((iKyiKyT - iK) * dKj) / 2;
      g(j) = -dlogp;
    end
  end

  %
  % Choosing several starting points.
  %
  leftCount = startCount - size(startValues, 1);
  if leftCount > 0
    leftValues = rand(leftCount, parameterCount);
    leftValues = bsxfun(@plus, lowerBound, leftValues);
    leftValues = bsxfun(@times, upperBound - lowerBound, leftValues);
    startValues = [ startValues; leftValues ];
  end

  options = optimset('Algorithm','interior-point', ...
    'GradObj', 'on', 'Display', 'off');

  results = zeros(startCount, parameterCount + 1);

  skipCount = 0;

  for i = 1:startCount
    try
      [ solution, fitness ] = fmincon(@target, ...
        log(startValues(i, :)), [], [], [], [], ...
        log(lowerBound), log(upperBound), [], options);
    catch e
      if strcmp(e.identifier, 'optim:barrier:UsrObjUndefAtX0')
        skipCount = skipCount + 1;
        solution = NaN(1, parameterCount);
        fitness = Inf;
      else
        throw(e);
      end
    end
    results(i, :) = [ solution, fitness ];
  end

  if skipCount == startCount
    error('All starting points have been skipped (%d in total).', startCount);
  elseif skipCount > 0
    warning('%d starting points have been skipped (out of %d).', ...
      skipCount, startCount);
  end

  [ ~, I ] = sort(results(:, end));
  parameters = exp(results(I(1), 1:parameterCount));
end
