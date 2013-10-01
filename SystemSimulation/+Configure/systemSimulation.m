function options = systemSimulation(varargin)
  options = Options(varargin{:});

  paths = { File.join(File.trace, '..', '+Test', 'Assets') };
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

  options.floorplan = File.choose(paths, ...
    sprintf('%03d.flp', processorCount));
  options.die = Die('floorplan', options.floorplan);

  %
  % Dynamic power
  %
  options.ensure('samplingInterval', 1e-3);
  options.power = DynamicPower( ...
    'samplingInterval', options.samplingInterval, 'powerScale', 1);
  options.dynamicPower = options.power.compute(options.schedule);

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
  options.ensure('referenceCircuit', 'ring_nangate_VTL_T_L_Tox');

  function parameter = configureParameter(name, parameter)
    if nargin < 2, parameter = Options; end
    switch name
    case 'T'
      parameter.reference = Utils.toKelvin(120);
      parameter.nominal   = Utils.toKelvin(50);
      parameter.range     = Utils.toKelvin([ 40, 400 ]);
    case 'L'
      parameter.reference = 50e-9;
      parameter.nominal   = 50e-9;
    case 'Tox'
      parameter.reference = 1e-9;
      parameter.nominal   = 1e-9;
    otherwise
      assert(false);
    end
  end

  leakageParameters = Options;
  leakageParameters.add('T', configureParameter('T'));

  processParameters = options.ensure('processParameters', { 'L', 'Tox' });
  for i = 1:length(processParameters)
    name = processParameters{i};
    leakageParameters.add(name, configureParameter(name));
  end

  options.leakageParameters = leakageParameters;

  %
  % Leakage power
  %
  options.leakageOptions = Options( ...
    'approximation', 'Interpolation.Linear', ...
    'filename', Name.leakageDataFile(options), ...
    'parameters', leakageParameters, ...
    'referencePower', 2 / 3 * mean(options.dynamicPower(:)), ...
    options.get('leakageOptions', []));

  %
  % Temperature
  %
  options.Tamb = Utils.toKelvin(45);
  options.hotspotConfig = File.choose(paths, 'hotspot.config');
end
