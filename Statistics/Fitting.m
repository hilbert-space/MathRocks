function surrogate = Fitting(varargin)
  options = Options(varargin{:});
  method = options.get('method', 'Interpolation');
  surrogate = Fitting.(method)(options);
end