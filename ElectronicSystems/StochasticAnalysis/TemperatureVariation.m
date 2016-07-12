function temperatureVariation = TemperatureVariation(varargin)
  options = Options(varargin{:});

  surrogate = options.get('surrogate', 'PolynomialChaos');

  temperatureVariation = TemperatureVariation.(surrogate)(options);
end
