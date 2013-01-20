function parameters = optimize(x, y, kernel, ...
  startValues, lowerBound, upperBound, startCount)

  if ~exist('startCount', 'var'), startCount = 1; end

  nodeCount = size(x, 1);
  parameterCount = length(lowerBound);
  assert(length(upperBound) == parameterCount);

  I = constructPairIndex(nodeCount);

  x1 = x(I(:, 1), :)';
  x2 = x(I(:, 2), :)';
  yT = y';

  function [ f, g ] = target(logParams)
    [ K, dK ] = kernel(x1, x2, exp(logParams));
    K = constructSymmetricMatrix(K, I);

    [ L, p ] = chol(K, 'lower');

    if p > 0
      f = NaN;
      g = NaN(1, parameterCount);
      return;
    end

    %
    % Reference:
    %
    % C. Rasmussen and C. Williams. Gaussian Processes for Machine Learning,
    % The MIT press, 2006, pp. 19, 113--114.
    %

    iK = L' \ (L \ eye(nodeCount));

    iKy = iK * y;
    iKyiKyT = iKy * iKy';

    %
    % NOTE: Since we assume y is n-dimensional, the product
    %
    %   y' * K^(-1) * y
    %
    % yeilds an (n x n) matrix. Assuming independence of the outputs,
    % we take the product of the corresponding probabilities (which is
    % a sum in the logarithmic space).
    %
    yTiKy = trace(yT * iKy);

    %
    % NOTE: Since due after Cholesky K = L * L^T, the sum of the diagonal
    % elements of L is the square root of the determinant of K; therefore,
    % we need to multiply by two in the logarithmic space.
    %
    logDetK = 2 * sum(log(diag(L)));

    %
    % NOTE: Formally, we should also subtract
    %
    %   nodeCount * log(2 * pi) / 2
    %
    % to get a complete log-likelihood.
    %
    logLikelihood = -yTiKy / 2 - logDetK / 2;
    f = -logLikelihood;

    %
    % Now, the gradient.
    %
    g = zeros(1, parameterCount);
    iKyiKyTmiKd2 = (iKyiKyT - iK) / 2;
    for j = 1:parameterCount
      dKj = constructSymmetricMatrix(dK(j, :), I);
      %
      % NOTE: Here is an efficent way to compute the trace of
      % the product of two square matrices.
      %
      dlogp = sum(sum(iKyiKyTmiKd2 .* dKj'));
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
