function [ y, x ] = computeDistribution(y, x, varargin)
  options = Options('method', 'smooth', 'quantity', 'pdf', varargin{:});

  if isempty(x)
    x = Utils.constructLinearSpace(y, options);
  end

  switch options.method
  case 'smooth'
    y = computeKernelDensity(y, x, options);
  case { 'histogram', 'piecewise' }
    y = computeHistogram(y, x, options);
  otherwise
    error('The method is unknown.');
  end
end

function y = computeHistogram(y, x, options)
  if length(x) == 1
    y = 1;
    return;
  end

  x = x(:);
  y = y(:);

  %
  % NOTE: The buckets are assumed to be evenly spaced.
  %
  assert(~any(abs(diff(diff(x))) > sqrt(eps)));
  dx = x(2) - x(1);

  y = histc(y, [ (x - dx / 2); x(end) + dx / 2 ]);
  y(end) = [];

  switch options.quantity
  case 'pdf'
    y = y / sum(y) / dx;
  case 'cdf'
    y = cumsum(y);
    y = y / y(end) / dx;
  otherwise
    error('The function is unknown.');
  end
end

function y = computeKernelDensity(y, x, options)
  y = ksdensity(y, x, 'function', options.quantity);
end
