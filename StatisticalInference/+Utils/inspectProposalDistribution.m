function inspectProposalDistribution(computeLogPosterior, theta, covariance)
  pointCount = 30; % Keep it even!

  theta = theta(:);
  parameterCount = length(theta);

  cols = floor(sqrt(parameterCount));
  rows = ceil(parameterCount / cols);

  c1 = Color.pick(1);
  c2 = Color.pick(2);

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

  figure;
  Plot.name('Curvature at the posterior mode');

  for i = 1:parameterCount
    subplot(rows, cols, i);

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
    % Plotting only grid points with the log-posterior not
    % more than 10 units away form the log-posterior mode.
    %
    I = find((logPosteriorMode - logPosterior) < 10);
    logPosterior = logPosterior(I);
    grid = grid(I);

    line(grid, logPosterior, 'Color', c1);

    logDensity = computeLogGaussianDensity( ...
      grid, theta(i), deviation(i));
    logDensityMode = computeLogGaussianDensity( ...
      theta(i), theta(i), deviation(i));

    line(grid, logDensity - logDensityMode + logPosteriorMode, 'Color', c2);

    box off;

    yBound = ylim;
    yBound = [ floor(yBound(1)), ceil(yBound(2)) ];
    xBound = [ lowerBound(i), upperBound(i) ];
    xBound = round(xBound * 100) / 100;

    line([ theta(i) theta(i) ], yBound, 'Color', 'k');

    if i == 1, Plot.legend('Optimized', 'Gaussian'); end
    Plot.limit(xBound, yBound);
    set(gca, 'XTick', xBound);
    set(gca, 'YTick', yBound);

    drawnow;
  end
end

function logDensity = computeLogGaussianDensity(x, mu, sigma)
  logDensity = -log(sigma) - 0.5 * log(2 * pi) - 0.5 * ((x - mu) ./ sigma).^2;
end
