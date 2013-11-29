function surrogate = Regression(varargin)
  options = Options(varargin{:});
  basis = options.get('basis', 'Polynomial');
  surrogate = Fitting.Regression.(basis)(options);
end