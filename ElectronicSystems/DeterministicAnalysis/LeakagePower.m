function leakage = LeakagePower(varargin)
  options = Options(varargin{:});
  dependency = options.get('dependency', 'Nonlinear');
  leakage = LeakagePower.(dependency)(options);
end
