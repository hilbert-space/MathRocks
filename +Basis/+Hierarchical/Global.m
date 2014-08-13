function basis = Global(varargin)
  options = Options(varargin{:});
  basis = options.get('basis', 'NewtonCotesHat');
  basis = Basis.Hierarchical.Global.(basis)(options);
end