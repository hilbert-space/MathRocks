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
  % Leakage power
  %
  function parameter = configureParameter(name, parameter)
    if nargin < 2, parameter = Options; end
    switch name
    case 'T'
      parameter.reference = Utils.toKelvin(120);
      parameter.nominal = Utils.toKelvin(50);
      parameter.range = Utils.toKelvin([ 40, 400 ]);
      return;
    case 'L'
      nominal = 50e-9;
      sigma = 0.05 * (nominal - (50e-9 - 22.5e-9));
    case 'Tox'
      nominal = 1e-9;
      sigma = 0.05 * nominal;
    otherwise
      assert(false);
    end
    parameter.reference = nominal;
    parameter.nominal = nominal;
    parameter.sigma = sigma;
    parameter.range = nominal + [ -4, 4 ] * sigma;
  end

  leakageParameters = Options;
  leakageParameters.add('T', configureParameter('T'));

  processParameters = options.ensure('processParameters', { 'L', 'Tox' });
  for i = 1:length(processParameters)
    name = processParameters{i};
    leakageParameters.add(name, configureParameter(name));
  end

  options.leakageParameters = leakageParameters;
  options.ensure('referenceCircuit', ...
    [ 'ring_nangate_VTL_', Name.parameters(leakageParameters) ]);

  %
  % Leakage power
  %
  options.leakageOptions = Options( ...
    'method', 'Interpolation.Linear', ...
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
