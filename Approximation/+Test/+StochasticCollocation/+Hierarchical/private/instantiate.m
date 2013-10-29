function surrogate = instantiate(options)
  surrogate = options.fetch( ...
    'surrogate', 'StochasticCollocation.Hierarchical.Local');
  surrogate = Utils.instantiate(surrogate, options);
end

