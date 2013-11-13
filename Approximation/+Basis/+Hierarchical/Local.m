function basis = Local(varargin)
  options = Options(varargin{:});
  basis = options.get('basis', 'NewtonCotesHat');
  basis = Basis.Hierarchical.Local.(basis)(options);
end