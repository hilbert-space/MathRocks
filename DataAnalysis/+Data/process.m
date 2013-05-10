function data = process(x, data, options)
  method = options.get('method', 'smooth');

  switch method
  case 'smooth'
    data = processKernelDensity(x, data, options);
  case 'histogram'
    data = processHistogram(x, data, options);
  case 'piecewise'
    data = processHistogram(x, data, options);
  otherwise
    error('The method is unknown.');
  end
end

function data = processHistogram(x, data, options)
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

  %
  % NOTE: We discard the last one due to 'help histc'.
  %
  data = histc(data, [ -Inf; x; Inf ]);
  data(end) = [];

  switch options.get('function', 'pdf')
  case 'pdf'
    data = data / sum(data);
  case 'cdf'
    data = cumsum(data);
    data = data / data(end);
  otherwise
    error('The function is unknown.');
  end
end

function data = processKernelDensity(x, data, options)
  data = ksdensity(data, x, ...
    'function', options.get('function', 'pdf'));
end
