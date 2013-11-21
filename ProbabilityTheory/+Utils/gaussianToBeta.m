function beta = gaussianToBeta(gaussian, varargin)
  %
  % NOTE: In what follows, it is assumed that the needed beta
  % distribution is symmetric; thus, alpha = beta.
  %
  options = Options(varargin{:});

  spread = options.get('spread', 3);
  a = options.get('a', gaussian.mu - spread * gaussian.sigma);
  b = options.get('b', gaussian.mu + spread * gaussian.sigma);

  switch options.get('target', 'pdf')
  case 'pdf'
    range = options.get('range', [ 1, 20 ]);

    options = optimoptions('fmincon');
    options.Algorithm = 'active-set';
    options.TolFun = 1e-10;
    options.Display = 'none';

    x = linspace(a, b, 50);
    f1 = gaussian.pdf(x);

    param = fmincon( ...
      @(param, varargin) Error.computeRMSE(f1, computeBeta(x, param)), ...
      mean(range), [], [], [], [], range(1), range(2), [], options);
  case 'variance'
    %
    % The alpha and beta parameters can be computed using
    %
    %                alpha * beta * (b - a)^2
    % Var(X) = ------------------------------------- .
    %          (alpha + bata)^2 * (alpha + beta + 1)
    %
    % Reference:
    %
    % http://en.wikipedia.org/wiki/Beta_distribution#Four_parameters_2
    %
    param = (b - a)^2 / 8 / (gaussian.variance) - 1 / 2;
  otherwise
    assert(false);
  end

  beta = ProbabilityDistribution.Beta( ...
    'alpha', param, 'beta', param, 'a', a, 'b', b);

  function result = computeBeta(x, param)
    beta = ProbabilityDistribution.Beta( ...
      'alpha', param, 'beta', param, 'a', a, 'b', b);
    result = beta.pdf(x);
  end
end
