function data = compute(x, data, options)
  options = Options('method', 'smooth', 'quantity', 'pdf', options);

  switch options.method
  case 'smooth'
    data = computeKernelDensity(x, data, options);
  case { 'histogram', 'piecewise' }
    data = computeHistogram(x, data, options);
  otherwise
    error('The method is unknown.');
  end
end

function data = computeHistogram(x, data, options)
  if length(x) == 1
    data = 1;
    return;
  end

  x = x(:);
  data = data(:);

  %
  % NOTE: The buckets are assumed to be evenly spaced.
  %
  assert(~any(abs(diff(diff(x))) > sqrt(eps)));
  dx = x(2) - x(1);

  data = histc(data, [ (x - dx / 2); x(end) + dx / 2 ]);
  data(end) = [];

  switch options.quantity
  case 'pdf'
    data = data / sum(data);
  case 'cdf'
    data = cumsum(data);
    data = data / data(end);
  otherwise
    error('The function is unknown.');
  end
end

function data = computeKernelDensity(x, data, options)
  data = ksdensity(data, x, 'function', options.quantity);
end
