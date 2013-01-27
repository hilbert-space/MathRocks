function parameters = optimize(x, y, kernel, noise)
  compute = kernel.compute;
  parameters = kernel.parameters;
  lowerBound = kernel.lowerBound;
  upperBound = kernel.upperBound;
  startCount = kernel.get('startCount', 1);

  nodeCount = size(x, 1);
  parameterCount = length(lowerBound);
  assert(length(upperBound) == parameterCount);

  I = Utils.constructPairIndex(nodeCount);

  x1 = x(I(:, 1), :)';
  x2 = x(I(:, 2), :)';
  yT = y';

  function [ f, g ] = target(logParams)
    [ K, dK ] = compute(x1, x2, exp(logParams));
    K = Utils.symmetrizePairIndex(K, I) + noise;

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
    % The MIT press, 2006, pp. 19, 37, 113--114.
    %

    iK = L' \ (L \ eye(nodeCount));
    iKy = iK * y;

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
    % NOTE: Since due after Cholesky K = L * L', the sum of the diagonal
    % elements of L is the square root of the determinant of K; therefore,
    % we need to multiply by two in the logarithmic space.
    %
    logDetK = 2 * sum(log(diag(L)));

    %
    % NOTE: The last term is constant and, thus, can be dropped. The
    % halving is also irrelevant for the optimization.
    %
    logLikelihood = -yTiKy / 2 - logDetK / 2 - nodeCount * log(2 * pi) / 2;
    f = -logLikelihood;

    if nargout == 1, return; end

    %
    % Now, the gradient.
    %
    g = zeros(1, parameterCount);
    alpha = (iKy * iKy' - iK)' / 2;
    for j = 1:parameterCount
      dKj = Utils.symmetrizePairIndex(dK(j, :), I);
      %
      % NOTE: Here is an efficient way to compute the trace of
      % the product of two square matrices.
      %
      dLogLikelihood = sum(sum(alpha .* dKj));
      g(j) = -dLogLikelihood;
    end
  end

  %
  % Decide on starting points.
  %
  if startCount == 1
    startValues = parameters;
  else
    p = rand(startCount - 1, parameterCount);
    mn = repmat(lowerBound, startCount - 1, 1);
    mx = repmat(upperBound, startCount - 1, 1);
    startValues = [ parameters; mn.^(1 - p) .* mx.^p ];
  end

  options = optimset('Algorithm','interior-point', ...
    'GradObj', 'on', 'Display', 'off');

  results = zeros(startCount, parameterCount + 1);

  skipCount = 0;

  for i = 1:startCount
    try
      %
      % Bounded or unbounded? That is the question...
      %
      % [ solution, fitness ] = fmincon(@target, ...
      %   log(startValues(i, :)), [], [], [], [], ...
      %   log(lowerBound), log(upperBound), [], options);
      %
      [ solution, fitness ] = fminunc(@target, log(startValues(i, :)), options);
    catch e
      if strcmp(e.identifier, 'optim:barrier:UsrObjUndefAtX0') || ...
        strcmp(e.identifier, 'optim:sfminbx:UsrObjUndefAtX0') || ...
        strcmp(e.identifier, 'MATLAB:eig:matrixWithNaNInf')

        skipCount = skipCount + 1;
        solution = NaN(1, parameterCount);
        fitness = Inf;
      else
        rethrow(e);
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
