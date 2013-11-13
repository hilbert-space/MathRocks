function basis = Local(varargin)
  options = Options(varargin{:});
  name = options.get('name', 'NewtonCotesHat');
  basis = Basis.Hierarchical.Local.(name)(options);
end