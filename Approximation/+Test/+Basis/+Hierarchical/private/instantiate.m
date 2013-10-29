function basis = instantiate(options)
  basis = options.fetch('basis', 'Local.NewtonCotesHat');
  basis = Utils.instantiate([ 'Basis.Hierarchical.', basis ], options);
end
