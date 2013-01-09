function [ values, functions ] = construct(this, options)
  %
  % Source:
  %
  % C. Rasmussen and C. Williams. Gaussian Processes for Machine Learning,
  % the MIT Press, 2006, pp. 97--98.
  %

  l = options.correlationLength;
  sigma = options.get('sigma', 1);

  a = 1 / (4 * sigma^2);
  b = 1 / (2 * l^2);
  c = sqrt(a^2 + 2 * a * b);

  A = a + b + c;
  B = b / A;

  if options.has('dimension')
    d = options.dimension;
  else
    d = NaN;
    t = options.threshold;
  end

  values = zeros(1, 0);
  functions = cell(1, 0);

  x = sympoly('x');

  H(1) = sympoly(1);
  H(2) = 2 * x;

  F{1} = @(y) ones(size(y));
  F{2} = @(y) 2 * y;

  k = 0;
  while true
    if k > 1
      H(k + 1) = 2 * x * H(k) - 2 * (k - 1) * H(k - 1);
      F{k + 1} = Utils.toFunction(H(k + 1), x, 'columns');
    end

    values(k + 1) = sqrt(pi / A) * B^k; % or sqrt(2 * a / A) ?
    functions{k + 1} = @(y) exp(-(c - a) * y.^2) .* F{k + 1}(sqrt(2 * c) * y);

    if isnan(d)
      if values(end) / sum(values) < t, break; end
    end

    k = k + 1;

    if ~isnan(d)
      if k >= d, break; end
    end
  end

  this.correlationLength = l;
  this.sigma = sigma;
end
