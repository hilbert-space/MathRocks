function options = systemSimulation(varargin)
  options = Options(varargin{:});

  paths = { File.join(File.trace, '..', 'Assets') };
  if options.has('assetPath')
    paths = [ { options.assetPath }, paths ];
  end

  %
  % Platform and application
  %
  processorCount = options.ensure('processorCount', 4);
  taskCount = options.ensure('taskCount', 20 * processorCount);

  [ options.platform, options.application ] = Utils.parseTGFF( ...
    File.choose(paths, sprintf('%03d_%03d.tgff', processorCount, taskCount)));
  options.schedule = Schedule.Dense(options.platform, options.application);

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

  options.die = Die('floorplan', ...
    File.choose(paths, sprintf('%03d.flp', processorCount)));
end
