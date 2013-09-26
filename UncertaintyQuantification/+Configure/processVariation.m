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

  %
  % Process parameters
  %
  processParameters = options.ensure('processParameters', { 'L' });

  %
  % Process variation
  %
  processVariationParameters = Options;

  for i = 1:length(processParameters)
    switch processParameters{i}
    case 'L'
      processVariationParameters.add('L', Options( ...
        'model', 'Gaussian', ...
        'expectation', 45e-9, ...
        'variance', (0.05 * 17.5e-9)^2, ...
        'correlation', { @correlate, eta, lse, lou }, ...
        'globalContribution', 0.5, ...
        'reductionThreshold', 0.96));
    case 'Tox'
      processVariationParameters.add('Tox', Options( ...
        'model', 'Gaussian', ...
        'expectation', 1.25e-9, ...
        'variance', (0.05 * 1.25e-9)^2, ...
        'correlation', { @correlate, eta, lse, lou }, ...
        'globalContribution', 0.5, ...
        'reductionThreshold', 0.96));
    otherwise
      assert(false);
    end
  end

  options.processOptions = Options( ...
    'die', options.die, 'parameters', processVariationParameters);
end
