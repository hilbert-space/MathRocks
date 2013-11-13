function surrogate = StochasticCollocation(varargin)
  options = Options(varargin{:});
  support = options.get('support', 'Local');
  surrogate = StochasticCollocation.(support)(options);
end