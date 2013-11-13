function interpolation = Interpolation(varargin)
  options = Options(varargin{:});
  structure = options.get('structure', 'Hierarchical');
  interpolation = Interpolation.(structure)(options);
end