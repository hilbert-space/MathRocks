function [ x, data ] = process(x, data, options)
  method = options.get('method', 'smooth');

  switch method
  case 'smooth'
    [ x, data ] = processKernelDensity(x, data, options);
  case 'histogram'
    [ x, data ] = processHistogram(x, data, options);
  case 'piecewise'
    [ x, data ] = processHistogram(x, data, options);
  otherwise
    error('The method is unknown.');
  end
end

function [ x, data ] = processHistogram(x, data, options)
  x = x(:);
  data = data(:);

  if length(x) == 1
    data = [ 1 ];
    return;
  end

  dx = x(2:end) - x(1:end - 1);
  dx = [ dx(1); dx; dx(end) ];

  data = histc(data, [ -Inf; x; Inf ]);
  data = data(1:end - 1) ./ dx;

  x = [ x(1) - dx(1); x ];

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

function [ x, data ] = processKernelDensity(x, data, options)
  data = ksdensity(data, x, ...
    'function', options.get('function', 'pdf'));
end
