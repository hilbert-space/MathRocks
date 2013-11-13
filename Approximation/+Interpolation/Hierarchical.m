function interpolant = Hierarchical(varargin)
  options = Options(varargin{:});
  support = options.get('support', 'Local');
  interpolant = Interpolation.Hierarchical.(support)(options);
end