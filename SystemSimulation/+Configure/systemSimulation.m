function options = systemSimulation(varargin)
  options = Options(varargin{:});

  path = File.join(File.trace, '..', '+Test', 'Assets');

  %
  % Platform and application
  %
  processorCount = options.getSet('processorCount', 4);
  taskCount = options.getSet('taskCount', 20 * processorCount);

  tgffFilename = options.get('tgffFilename', ...
    File.join(path, sprintf('%03d_%03d.tgff', processorCount, taskCount)));
  [ options.platform, options.application ] = Utils.parseTGFF(tgffFilename);
  options.schedule = Schedule.Dense(options.platform, options.application);

  readProcessorCount = length(options.platform.processors);
  assert(readProcessorCount == processorCount);

  readTaskCount = length(options.application.tasks);
  if readTaskCount ~= taskCount
    %
    % NOTE: It is a rather common thing for TGFF.
    %
    taskCount = readTaskCount;
    options.taskCount = readTaskCount;
  end

  options.die = Die('floorplan', ...
    File.join(path, sprintf('%03d.flp', processorCount)));

  %
  % Dynamic power
  %
  options.power = DynamicPower(options.getSet('samplingInterval', 1e-3));
  options.dynamicPower = options.getSet('powerScale', 1) * ...
    options.power.compute(options.schedule);

  if options.has('stepCount')
    options.dynamicPower = Utils.stretch( ...
      options.dynamicPower, options.stepCount);
  else
    options.stepCount = size(options.dynamicPower, 2);
  end

  options.timeLine = (0:(options.stepCount - 1)) * options.samplingInterval;

  resample = options.get('resample', 1);
  if resample > 1
    options.stepCount = options.stepCount * resample;
    options.samplingInterval = options.samplingInterval / resample;
    options.dynamicPower = Utils.resample(options.dynamicPower, resample);
  end

  %
  % Leakage power
  %
  options.getSet('leakageModel' , 'LinearInterpolation');
  options.leakageOptions = Options( ...
    'dynamicPower', options.dynamicPower, ...
    'filename', File.join(path, 'inverter_45nm_L5_T1000_08.leak'), ...
    options.get('leakageOptions', Options()));

  %
  % Temperature
  %
  options.hotspotOptions = Options( ...
    'config', File.join(path, 'hotspot.config'), ...
    'line', sprintf('sampling_intvl %.4e', options.samplingInterval), ...
    options.get('hotspotOptions', Options()));
end
