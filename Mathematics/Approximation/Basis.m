function basis = Basis(varargin)
  options = Options(varargin{:});
  structure = options.get('structure', 'Hierarchical');
  basis = Basis.(structure)(options);
end
