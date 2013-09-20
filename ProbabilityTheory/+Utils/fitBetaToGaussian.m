function param = fitBetaToGaussian(varargin)
  options = Options(varargin{:});

  sigma = options.sigma;
  fitRange = options.get('fitRange', [ -4 * sigma, 4 * sigma ]);
  paramRange = options.get('paramRange', [ 1, 20 ]);

  Normal = ProbabilityDistribution.Gaussian( ...
    'mu', 0, 'sigma', sigma);

  x = linspace(fitRange(1), fitRange(2), 50);
  f1 = Normal.pdf(x);

  function e = compare(param, varargin)
    Beta = ProbabilityDistribution.Beta( ...
      'alpha', param, 'beta', param, 'a', fitRange(1), 'b', fitRange(2));
    f2 = Beta.pdf(x);
    e = Error.computeRMSE(f1, f2);
  end

  options = optimoptions('fmincon');
  options.Algorithm = 'active-set';
  options.TolFun = 1e-10;
  options.Display = 'none';

  param = fmincon(@compare, mean(paramRange), [], [], [], [], ...
    paramRange(1), paramRange(2), [], options);
end
