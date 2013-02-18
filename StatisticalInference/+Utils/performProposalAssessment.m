function assessment = performProposalAssessment( ...
  logPosteriorFunction, theta, covariance, varargin)

  options = Options(varargin{:});
  pointCount = options.get('pointCount', 30);

  assert(rem(pointCount, 2) == 0); % Keep it even!

  parameterCount = length(theta);
  logPosteriorMode = feval(logPosteriorFunction, theta);

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

  Grid = repmat(theta, [ 1, parameterCount, pointCount + 1 ]);
  for i = 1:parameterCount
    grid = lowerBound(i):stepLength(i):upperBound(i);
    grid = [ grid(1:(pointCount / 2)), theta(i), ...
      grid((pointCount / 2 + 1):pointCount) ];
    Grid(i, i, :) = grid;
  end
  Grid = reshape(Grid, parameterCount, []);

  logPosterior = zeros(1, size(Grid, 2));
  parfor i = 1:size(Grid, 2)
    logPosterior(i) = feval(logPosteriorFunction, Grid(:, i));
  end
  logPosterior = reshape(logPosterior, parameterCount, pointCount + 1);
  Grid = reshape(Grid, parameterCount, parameterCount, pointCount + 1);

  for i = 1:parameterCount
    %
    % Keep only grid points with the log-posterior not
    % more than 10 units away form the log-posterior mode.
    %
    I = find((logPosteriorMode - logPosterior(i, :)) < 10);

    grid = squeeze(Grid(i, i, I));

    logPosteriorApproximation = ...
      computeLogGaussianDensity(grid, theta(i), deviation(i)) - ...
      computeLogGaussianDensity(theta(i), theta(i), deviation(i)) + ...
      logPosteriorMode;

    assessment(i).grid = grid;
    assessment(i).logPosterior = logPosterior(i, I);
    assessment(i).logPosteriorApproximation = logPosteriorApproximation;
  end
end

function logDensity = computeLogGaussianDensity(x, mu, sigma)
  logDensity = -log(sigma) - 0.5 * log(2 * pi) - 0.5 * ((x - mu) ./ sigma).^2;
end
