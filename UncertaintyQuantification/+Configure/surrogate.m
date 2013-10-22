function options = surrogate(varargin)
  options = Options(varargin{:});

  surrogate = options.ensure('surrogate', 'PolynomialChaos');

  switch surrogate
  case 'PolynomialChaos'
    options.surrogateOptions = Options('order', 3, ...
      'quadratureOptions', Options('method', 'adaptive'));
  case 'SparseGrid'
    options.surrogateOptions = Options( ...
      'absoluteTolerance', 1e-3, ...
      'relativeTolerance', 1e-2, ...
      'maximalLevel', 5, ...
      'verbose', true);
  otherwise
    assert(false);
  end
end
