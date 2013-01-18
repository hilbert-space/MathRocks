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
    dK = constructSymmetricMatrix(dK, I);

    [ V, L ] = eig(K);
    L = max(0, diag(L));

    iK = V * diag(1 ./ L) * V';

    iKy = iK * responses;
    iKyiKyT = iKy * iKy';

    logp = -sum(diag(responses' * iKy)) / 2 - ...
      sum(log(L)) / 2 - nodeCount * log(2 * pi) / 2;
    dlogp = trace((iKyiKyT - iK) * dK) / 2;

    f = -logp;
    g = -dlogp;
  end

  %
  % Choosing several starting points.
  %
  leftCount = startCount - size(startValues, 1);
  leftValues = rand(leftCount, parameterCount);
  leftValues = bsxfun(@plus, lowerBound, leftValues);
  leftValues = bsxfun(@times, upperBound - lowerBound, leftValues);
  startValues = [ startValues; leftValues ];

  options = optimset('Algorithm','interior-point', ...
    'GradObj', 'on', 'Display', 'off');

  results = zeros(startCount, parameterCount + 1);
  for i = 1:startCount
    [ results(i, 1:parameterCount), results(i, end) ] = ...
      fmincon(@target, log(startValues(i, :)), [], [], [], [], ...
        log(lowerBound), log(upperBound), [], options);
  end
  [ ~, I ] = sort(results(:, end));

  parameters = exp(results(I(1), 1:parameterCount));
end
