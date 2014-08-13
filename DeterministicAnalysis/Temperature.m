function temperature = Temperature(varargin)
  options = Options(varargin{:});

  solution = options.get('solution', 'Analytical');
  analysis = options.get('analysis', 'Transient');

  temperature = Temperature.(solution).(analysis)(options);
end
