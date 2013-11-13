function surrogate = Interpolation(varargin)
  options = Options(varargin{:});
  structure = options.get('structure', 'Hierarchical');
  surrogate = Interpolation.(structure)(options);
end