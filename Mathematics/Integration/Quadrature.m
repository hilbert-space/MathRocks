function quadrature = Quadrature(varargin)
  options = Options(varargin{:});
  rule = options.get('rule', 'GaussHermite');
  quadrature = Quadrature.(rule)(options);
end