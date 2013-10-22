function surrogate = instantiate(surrogate, analysis, varargin)
  surrogate = Utils.instantiate( ...
    [ 'Temperature.', surrogate, '.', analysis ], varargin{:});
end