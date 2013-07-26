function options = processVariation(varargin)
  options = Options(varargin{:});

  expectation = options.get('expectation', 45e-9);
  deviation = options.get('deviation', 0.05 * expectation);

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

  options.getSet('processModel', 'Normal');
  options.processOptions = Options( ...
    'die', options.die, ...
    'expectation', expectation, ...
    'deviation', deviation, ...
    'kernel', { @correlate, eta, lse, lou }, ...
    'globalPortion', 0.5, ...
    'reductionThreshold', 0.99);
end
