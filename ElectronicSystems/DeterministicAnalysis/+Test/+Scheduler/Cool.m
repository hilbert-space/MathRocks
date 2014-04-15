function Cool(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.deterministicAnalysis(options, ...
    'temperatureOptions', Options( ...
      'analysis', 'StaticSteadyState'));

  plot(options.scheduler, options.schedule);

  temperature = Temperature(options.temperatureOptions);

  scheduler = Scheduler.Cool( ...
    'platform', options.platform, ...
    'application', options.application, ...
    'temperature', temperature, ...
    'criticalityScale', 0.01);

  schedule = scheduler.compute;
  plot(scheduler, schedule);
end
