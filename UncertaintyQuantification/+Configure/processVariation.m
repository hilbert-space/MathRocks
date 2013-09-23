function options = processVariation(varargin)
  options = Options(varargin{:});

  %
  % Process variation
  %
  function K = correlate(eta, lse, lou, s, t)
    %
    % Squared exponential kernel
    %
    Kse = exp(-sum((s - t).^2, 1) / lse^2);

    %
    % Ornstein-Uhlenbeck kernel
    %
    rs = sqrt(sum(s.^2, 1));
    rt = sqrt(sum(t.^2, 1));
    Kou = exp(-abs(rs - rt) / lou);

    K = eta * Kse + (1 - eta) * Kou;
  end

  eta = 0.50;
  lse = 0.50 * sqrt(options.die.width^2 + options.die.height^2);
  lou = lse;

  processParameters = Options( ...
    'L', Options( ...
      'model', 'Gaussian', ...
      'expectation', 45e-9, ...
      'variance', (0.05 * 45e-9)^2, ...
      'correlation', { @correlate, eta, lse, lou }, ...
      'globalContribution', 0.5, ...
      'reductionThreshold', 0.96));

  options.processOptions = Options( ...
    'die', options.die, 'parameters', processParameters);
end
