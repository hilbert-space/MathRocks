function options = deterministicAnalysis(varargin)
  options = Options(varargin{:});

  options.assetPath = [ options.get('assetPath', {}), ...
    { File.join(File.trace, '..', 'Assets') } ];

  %
  % Dynamic power
  %
  options.ensure('samplingInterval', 1e-3);
  options.power = DynamicPower('samplingInterval', options.samplingInterval, ...
    'powerScale', options.get('powerScale', 1));
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
  % Technological process
  %
  processParameters = options.get('processParameters', { 'Leff', 'Tox' });
  if ~isa(processParameters, 'Options')
    processParameters = Options(processParameters, []);
  end

  names = fieldnames(processParameters);
  for i = 1:length(names)
    parameter = processParameters.(names{i});
    if isempty(parameter), parameter = Options; end

    %
    % According to the technology requirements published by ITRS 2011,
    % the critical dimensions (CDs) should be controlled within 12%.
    %
    % Since about 99.7% of values drawn from a Gaussian distribution are
    % within three standard deviatiosn away from the mean, we let
    %
    %  3 * sigma = 0.12 * mu, that is,
    %
    %  sigma = 0.12 * mu / 3 = 0.04 * mu.
    %
    % Reference:
    %
    % http://www.itrs.net/Links/2011ITRS/2011Tables/Design_2011Tables.xlsx
    % (see Table DESN10)
    %
    % https://en.wikipedia.org/wiki/Normal_distribution#Standard_deviation_and_tolerance_intervals
    %

    switch names{i}
    case 'Leff'
      nominal = 22.5e-9;
    case 'Tox'
      nominal = 1e-9;
    otherwise
      assert(false);
    end

    parameter.nominal = nominal;
    parameter.sigma = 0.04 * nominal;
    parameter.range = nominal + [ -3, 3 ] * parameter.sigma; % see above
    parameter.reference = nominal;

    processParameters.(names{i}) = parameter;
  end

  options.processParameters = processParameters;

  %
  % Leakage power
  %
  leakageParameters = Options;
  leakageParameters.add('T', struct( ...
    'nominal', Utils.toKelvin(45), ...
    'range', Utils.toKelvin([ 45, 450 ]), ...
    'reference', Utils.toKelvin(120)));
  leakageParameters.update(processParameters);

  options.leakageOptions = Options( ...
    'method', 'Interpolation.Linear', ...
    'circuit', Circuit('name', 'ring_nangate_VTL', ...
      'parameters', leakageParameters), ...
    'parameters', leakageParameters, ...
    'referencePower', 2 / 3 * mean(options.dynamicPower(:)), ...
    options.get('leakageOptions', []));

  %
  % Temperature
  %
  options.temperatureOptions = Options( ...
    ... Main
    'method', 'Analytical', ...
    'analysis', 'Transient', ...
    ... General
    'processorCount', options.processorCount, ...
    'floorplan', options.die.filename, ...
    'hotspotConfig', File.choose(options.assetPath, 'hotspot.config'), ...
    'samplingInterval', options.samplingInterval, ...
    'ambientTemperature', min(leakageParameters.T.range), ...
    'leakageOptions', options.leakageOptions, ...
    ... Dynamic Steady-State
    'algorithm', 1, ...
    'maximalTemperature', max(leakageParameters.T.range), ...
    'convergenceMetric', 'NRMSE', ...
    'convergenceTolerance', 0.01, ... % below 1%
    'iterationLimit', 10, ...
    options.get('temperatureOptions', []));
end
