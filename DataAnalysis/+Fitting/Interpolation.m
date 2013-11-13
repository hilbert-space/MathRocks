function surrogate = Interpolation(varargin)
  options = Options(varargin{:});
  basis = options.get('basis', 'Linear');
  surrogate = Fitting.Interpolation.(basis)(options);
end