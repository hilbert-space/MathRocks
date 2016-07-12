function options = dynamicPower(options)
  options.ensure('samplingInterval', 1e-3);

  options.power = DynamicPower( ...
    'platform', options.platform, ...
    'application', options.application, ...
    'samplingInterval', options.samplingInterval, ...
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
end