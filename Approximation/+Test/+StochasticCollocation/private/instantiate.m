function surrogate = instantiate(options)
  surrogate = options.fetch('surrogate', 'StochasticCollocation.Local');
  surrogate = Utils.instantiate(surrogate, options);
end