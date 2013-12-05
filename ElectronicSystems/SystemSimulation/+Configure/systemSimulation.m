function options = systemSimulation(varargin)
  options = Options(varargin{:});

  options.assetPath = [ options.get('assetPath', {}), ...
    { File.join(File.trace, '..', 'Assets') } ];

  %
  % Platform and application
  %
  processorCount = options.ensure('processorCount', 4);
  taskCount = options.ensure('taskCount', 20 * processorCount);

  [ options.platform, options.application ] = Utils.parseTGFF( ...
    File.choose(options.assetPath, sprintf('%03d_%03d.tgff', ...
    processorCount, taskCount)));

  readProcessorCount = length(options.platform.processors);
  assert(readProcessorCount == processorCount);

  readTaskCount = length(options.application.tasks);
  if readTaskCount ~= taskCount
    %
    % NOTE: It is a rather common issue for TGFF.
    %
    taskCount = readTaskCount;
    options.taskCount = taskCount;
  end

  %
  % Die
  %
  options.die = Die('floorplan', File.choose(options.assetPath, ...
    sprintf('%03d.flp', processorCount)));

  %
  % Mapping and schedule
  %
  if options.has('mapping')
    mapping = options.mapping(processorCount, taskCount);
  else
    mapping = [];
  end

  if options.has('priority')
    priority = options.priority(processorCount, taskCount);
  else
    priority = [];
  end

  options.scheduler = Scheduler.Dense('platform', options.platform, ...
    'application', options.application);
  options.schedule = options.scheduler.compute(mapping, priority);
end
