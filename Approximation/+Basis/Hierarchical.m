function basis = Hierarchical(varargin)
  options = Options(varargin{:});
  support = options.get('support', 'Local');
  basis = Basis.Hierarchical.(support)(options);
end