function surrogate = instantiate(options)
  surrogate = options.fetch('surrogate', 'Interpolation.Hierarchical.Local');
  surrogate = Utils.instantiate(surrogate, options);
end

