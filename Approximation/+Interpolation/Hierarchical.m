function surrogate = Hierarchical(varargin)
  options = Options(varargin{:});
  support = options.get('support', 'Local');
  surrogate = Interpolation.Hierarchical.(support)(options);
end