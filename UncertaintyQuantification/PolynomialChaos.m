function surrogate = PolynomialChaos(varargin)
  options = Options(varargin{:});
  basis = options.get('basis', 'Hermite');
  surrogate = PolynomialChaos.(basis)(options);
end