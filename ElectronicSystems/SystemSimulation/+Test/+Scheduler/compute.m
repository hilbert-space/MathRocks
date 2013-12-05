function compute(varargin)
  setup;

  options = Options(varargin{:});
  iterationCount = options.get('iterationCount', 100);

  [ platform, application ] = Utils.parseTGFF( ...
    File.join('Assets', '032_640.tgff'));

  processorCount = length(platform);
  taskCount = length(application);

  rng(0);
  mapping = randi(processorCount, 1, taskCount);
  priority = rand(1, taskCount);

  scheduler = Scheduler.Dense( ...
    'platform', platform, 'application', application);

  fprintf('%s: scheduling %d tasks onto %d processors...\n', ...
    class(scheduler), taskCount, processorCount);
  time = tic;
  for i = 1:iterationCount
    scheduler.compute(mapping, priority);
  end
  fprintf('%s: average computational time is %.2f seconds.\n', ...
    class(scheduler), toc(time) / iterationCount);
end
