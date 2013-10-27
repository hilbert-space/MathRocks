function surrogate = instantiate(options)
  surrogate = options.fetch('surrogate', 'SparseGridInterpolation.Local');
  surrogate = Utils.instantiate(surrogate, options);
end

