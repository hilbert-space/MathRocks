function surrogate = instantiate(surrogate, analysis, varargin)
  surrogate = Utils.instantiate([ 'TemperatureVariation.', ...
    surrogate, '.', analysis ], varargin{:});
end