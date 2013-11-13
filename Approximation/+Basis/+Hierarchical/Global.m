function basis = Global(varargin)
  options = Options(varargin{:});
  name = options.get('name', 'NewtonCotesHat');
  basis = Basis.Hierarchical.Global.(name)(options);
end