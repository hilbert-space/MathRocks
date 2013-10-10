function options = surrogate(varargin)
  options = Options(varargin{:});

  surrogate = options.ensure('surrogate', 'Chaos');

  switch surrogate
  case 'Chaos'
    options.surrogateOptions = Options('order', 4, ...
      'quadratureOptions', Options('method', 'adaptive'));
  case 'ASGC'
    options.surrogateOptions = Options( ...
      'tolerance', 1e-3, ...
      'maximalLevel', 4, ...
      'verbose', true);
  otherwise
    assert(false);
  end
end
