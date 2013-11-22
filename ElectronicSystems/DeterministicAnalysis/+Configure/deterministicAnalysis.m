function options = deterministicAnalysis(varargin)
  options = Options(varargin{:});

  paths = { File.join(File.trace, '..', 'Assets') };
  if options.has('assetPath')
    paths = [ { options.assetPath }, paths ];
  end

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
  % Technological process
  %
  processParameters = options.get('processParameters', { 'L', 'Tox' });
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
    case 'L'
      nominal = 50e-9;
      sigma = 0.04 * (nominal - (50e-9 - 22.5e-9));
    case 'Tox'
      nominal = 1e-9;
      sigma = 0.04 * nominal;
    otherwise
      assert(false);
    end

    parameter.reference = nominal;
    parameter.nominal = nominal;
    parameter.sigma = sigma;
    parameter.range = nominal + [ -3, 3 ] * sigma; % see above

    processParameters.(names{i}) = parameter;
  end

  options.processParameters = processParameters;

  %
  % Leakage power
  %
  leakageParameters = Options;
  leakageParameters.add('T', struct( ...
    'reference', Utils.toKelvin(120), ...
    'nominal', Utils.toKelvin(50), ...
    'range', Utils.toKelvin([ 40, 400 ])));
  leakageParameters.update(processParameters);

  options.leakageOptions = Options( ...
    'method', 'Interpolation.Linear', ...
    'filename', Name.leakageDataFile( ...
      'referenceCircuit', [ 'ring_nangate_VTL_', ...
      Name.parameters(leakageParameters) ]), ...
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
    'hotspotConfig', File.choose(paths, 'hotspot.config'), ...
    'samplingInterval', options.samplingInterval, ...
    'ambientTemperature', Utils.toKelvin(45), ...
    'leakageOptions', options.leakageOptions, ...
    ... Dynamic Steady-State
    'algorithm', 1, ...
    'iterationLimit', 10, ...
    'temperatureLimit', Utils.toKelvin(400), ...
    'convergenceTolerance', 0.1, ...
    options.get('temperatureOptions', []));
end
