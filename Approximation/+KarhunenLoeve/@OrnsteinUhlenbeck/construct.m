function [ functions, values ] = construct(this, options)
  %
  % Source:
  %
  % R. Ghanem. Stochastic Finite Elements - A Spectral Approach.
  % Dover Publications, 1991, pp. 26--29.
  %

  epsilon = 1e-6;

  a = options.domainBoundary;
  c = 1 / options.correlationLength;

  if options.has('dimensionCount')
    dimension = options.dimensionCount;
  else
    dimension = NaN;
    threshold = options.threshold;
  end

  omegas = zeros(1, 0);
  functions = cell(1, 0);
  values = zeros(1, 0);

  even = @(x) c - x * tan(a * x);
  odd  = @(x) x + c * tan(a * x);

  i = 0;
  while true
    i = i + 1;

    if ~isnan(dimension)
      if i > dimension, break; end
    end

    left  = (pi / (2 * a)) * (i - 1) + epsilon;
    right = (pi / (2 * a)) * (i    ) - epsilon;

    if mod(i - 1, 2) == 0
      omegas(i) = bisect(left, right, even);
    else
      omegas(i) = bisect(left, right, odd);
    end

    if mod(i - 1, 2) == 0
      functions{i} = @(x) cos(omegas(i) * x) / ...
        sqrt(a + (sin(2 * omegas(i) * a)) / (2 * omegas(i)));
    else
      functions{i} = @(x) sin(omegas(i) * x) / ...
        sqrt(a - (sin(2 * omegas(i) * a)) / (2 * omegas(i)));
    end

    values(i) = (2 * c) / (omegas(i)^2 + c^2);

    if isnan(dimension) && Utils.isSignificant(values, threshold), break; end
  end
end
