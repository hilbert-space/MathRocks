function assessment = performProposalAssessment( ...
  computeLogPosterior, theta, covariance, varargin)

  options = Options(varargin{:});
  pointCount = options.get('pointCount', 30);

  assert(rem(pointCount, 2) == 0); % Keep it even!

  theta = theta(:);
  parameterCount = length(theta);

  %
  % Compute approximate conditional standard deviations.
  %
  deviation = zeros(parameterCount, 1);
  for i = 1:parameterCount
    I  = setdiff(1:parameterCount, i);
    deviation(i) = sqrt(covariance(i, i) - ...
      covariance(i, I) * inv(covariance(I, I)) * covariance(I, i));
  end

  lowerBound = theta - 4 * deviation;
  upperBound = theta + 4 * deviation;
  stepLength = (8 * deviation) / (pointCount - 1);

  for i = 1:parameterCount
    grid = lowerBound(i):stepLength(i):upperBound(i);
    grid = [ grid(1:(pointCount / 2)), theta(i), ...
      grid((pointCount / 2 + 1):pointCount) ];

    logPosterior = zeros(1, length(grid));

    point = theta;
    logPosteriorMode = computeLogPosterior(point);

    for j = 1:length(grid)
      point(i) = grid(j);
      logPosterior(j) = computeLogPosterior(point);
    end

    %
    % Keep only grid points with the log-posterior not
    % more than 10 units away form the log-posterior mode.
    %
    I = find((logPosteriorMode - logPosterior) < 10);
    grid = grid(I);
    logPosterior = logPosterior(I);

    logPosteriorApproximation = ...
      computeLogGaussianDensity(grid, theta(i), deviation(i)) - ...
      computeLogGaussianDensity(theta(i), theta(i), deviation(i)) + ...
      logPosteriorMode;

    assessment(i).grid = grid;
    assessment(i).logPosterior = logPosterior;
    assessment(i).logPosteriorApproximation = logPosteriorApproximation;
  end
end

function logDensity = computeLogGaussianDensity(x, mu, sigma)
  logDensity = -log(sigma) - 0.5 * log(2 * pi) - 0.5 * ((x - mu) ./ sigma).^2;
end
