function surrogate = instantiate(options)
  surrogate = options.fetch('surrogate', 'SparseGrid.SpaceAdaptive');
  surrogate = Utils.instantiate([ 'Interpolation.', surrogate ], options);
end

