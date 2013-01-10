function [ values, functions ] = construct(this, options)
  %
  % Source:
  %
  % R. Ghanem. Stochastic Finite Elements - A Spectral Approach.
  % Dover Publications, 1991, pp. 26--29.
  %

  epsilon = 1e-6;

  a = options.domainBoundary;
  c = 1 / options.correlationLength;

  if options.has('dimension')
    d = options.dimension;
  else
    d = NaN;
    t = options.threshold;
  end

  omegas = zeros(1, 0);
  values = zeros(1, 0);
  functions = cell(1, 0);

  even = @(x) c - x * tan(a * x);
  odd  = @(x) x + c * tan(a * x);

  i = 0;
  while true
    i = i + 1;

    if ~isnan(d)
      if i > d, break; end
    end

    left  = (pi / (2 * a)) * (i - 1) + epsilon;
    right = (pi / (2 * a)) * (i    ) - epsilon;

    if mod(i - 1, 2) == 0
      omegas(i) = bisect(left, right, even);
    else
      omegas(i) = bisect(left, right, odd);
    end

    values(i) = (2 * c) / (omegas(i)^2 + c^2);

    if mod(i - 1, 2) == 0
      functions{i} = @(x) cos(omegas(i) * x) / ...
        sqrt(a + (sin(2 * omegas(i) * a)) / (2 * omegas(i)));
    else
      functions{i} = @(x) sin(omegas(i) * x) / ...
        sqrt(a - (sin(2 * omegas(i) * a)) / (2 * omegas(i)));
    end

    if isnan(d)
      if values(end) / sum(values) < (1 - t), break; end
    end
  end

  this.correlationLength = options.correlationLength;
end
