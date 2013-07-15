function options = processVariation(varargin)
  options = Options(varargin{:});

  if options.has('nominal')
    expectation = options.nominal;
  else
    expectation = LeakagePower.Base.Lnom;
  end

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
  lse = 0.50 * max(options.die.width, options.die.height);
  lou = lse;

  options.getSet('processModel', 'Beta');
  options.processOptions = Options( ...
    'die', options.die, ...
    'expectation', expectation, ...
    'deviation', deviation, ...
    'kernel', { @correlate, eta, lse, lou }, ...
    'globalPortion', 0.5, ...
    'threshold', 0.99);
end
