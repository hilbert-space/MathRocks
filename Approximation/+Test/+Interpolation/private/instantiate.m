function surrogate = instantiate(options)
  surrogate = options.fetch('surrogate', 'Local');
  surrogate = Utils.instantiate( ...
    [ 'Interpolation.Hierarchical.', surrogate ], options);
end