function Critical(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.deterministicAnalysis(options, ...
    'temperatureOptions', Options( ...
      'analysis', 'StaticSteadyState'));

  plot(options.scheduler, options.schedule);

  temperature = Temperature(options.temperatureOptions);

  function penalty = penalize(energy, time)
    T = temperature.compute(energy / time);
    penalty = 0.01 * max(T(:));
  end

  scheduler = Scheduler.Critical( ...
    'platform', options.platform, ...
    'application', options.application, ...
    'penalize', @penalize);

  schedule = scheduler.compute;
  plot(scheduler, schedule);
end
