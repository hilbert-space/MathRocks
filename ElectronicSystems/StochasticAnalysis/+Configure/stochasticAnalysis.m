function options = stochasticAnalysis(varargin)
  options = Options(varargin{:});

  %
  % Process variation
  %
  eta = 2 / 3;
  lse = options.die.radius;
  lou = options.die.radius;

  function K = correlate(s, t)
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

  %
  % Process variation
  %
  processParameters = options.processParameters;

  parameterOptions = Options( ...
    'distribution', 'Beta', ...
    'transformation', 'Gaussian', ...
    'correlation', @correlate, ...
    'reductionThreshold', 0.95, ...
    options.get('parameterOptions', []));

  for i = 1:length(processParameters)
    parameter = processParameters.get(i);

    parameter.distribution = parameterOptions.distribution;
    parameter.transformation = parameterOptions.transformation;
    parameter.expectation = parameter.nominal;
    parameter.variance = parameter.sigma^2;
    parameter.correlation = parameterOptions.correlation;
    parameter.reductionThreshold = parameterOptions.reductionThreshold;

    processParameters.set(i, parameter);
  end

  options.processOptions = Options( ...
    'die', options.die, ...
    'parameters', processParameters, ...
    options.get('processOptions', []));

  %
  % Temperature variation
  %
  switch options.ensure('surrogate', 'PolynomialChaos')
  case 'MonteCarlo'
    options.surrogateOptions = Options( ...
      'sampleCount', 1e4, ...
      options.get('surrogateOptions', []));
  case 'PolynomialChaos'
    options.surrogateOptions = Options( ...
      'order', 4, 'anisotropic', 0, ...
      'quadratureOptions', Options('method', 'minimal'), ...
      options.get('surrogateOptions', []));
  case { 'StochasticCollocation', 'Interpolation' }
    options.surrogateOptions = Options( ...
      'method', 'Global', ...
      'basis', 'ChebyshevLagrange', ...
      'absoluteTolerance', 1e-1, ...
      'relativeTolerance', 1e-2, ...
      'maximalLevel', 10, ...
      'maximalNodeCount', 1e4, ...
      'verbose', true, ...
      options.get('surrogateOptions', []));
  otherwise
    assert(false);
  end
end
