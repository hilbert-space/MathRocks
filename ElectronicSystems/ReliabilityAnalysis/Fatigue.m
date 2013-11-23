function fatigue = Fatigue(varargin)
  options = Options(varargin{:});

  mechanism = options.get('mechanism', 'ThermalCycling');

  fatigue = Fatigue.(mechanism)(options);
end
