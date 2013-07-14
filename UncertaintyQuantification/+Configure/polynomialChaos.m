function options = polynomialChaos(varargin)
  options = Options(varargin{:});

  options.surrogateOptions = Options('order', 4, ...
    'quadratureOptions', Options('method', 'adaptive'));
end
