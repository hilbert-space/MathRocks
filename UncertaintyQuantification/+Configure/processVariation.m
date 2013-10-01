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
  % System parameters
  %
  function parameter = configureParameter(name, parameter)
    if nargin < 2, parameter = Options; end
    parameter.model = 'Gaussian';
    switch name
    case 'L'
      expectation = parameter.get('nominal', 50e-9);
      parameter.expectation = expectation;
      parameter.variance = (0.05 * (expectation - (50e-9 - 22.5e-9)))^2;
    case 'Tox'
      expectation = parameter.get('nominal', 1e-9);
      parameter.expectation = expectation;
      parameter.variance = (0.05 * expectation)^2;
    otherwise
      assert(false);
    end
    parameter.correlation = { @correlate, eta, lse, lou };
    parameter.globalContribution = 0.5;
    parameter.reductionThreshold = 0.96;
  end

  leakageParameters = options.ensure('leakageParameters', Options);
  processParameters = options.ensure('processParameters', { 'L', 'Tox' });
  for i = 1:length(processParameters)
    name = processParameters{i};
    leakageParameters.(name) = configureParameter( ...
      name, leakageParameters.get(name, Options));
  end

  options.processOptions = Options('die', options.die, ...
    'parameters', leakageParameters.subset(processParameters));
end
