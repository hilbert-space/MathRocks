function surrogate = instantiate(options)
  surrogate = options.fetch('surrogate', 'Local');
  surrogate = Utils.instantiate([ ...
    'StochasticCollocation.', surrogate ], options);
end