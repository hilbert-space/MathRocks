function options = deterministicAnalysis(varargin)
  options = Options(varargin{:});

  options.assetPath = [options.get('assetPath', {}), ...
    { File.join(File.trace, '..', 'Assets') }];

  %
  % Dynamic power
  %
  options = Configure.dynamicPower(options);

  %
  % Technological process
  %
  options = Configure.technologicalProcess(options);

  %
  % Leakage power
  %
  options = Configure.leakagePower(options);

  %
  % Temperature
  %
  options = Configure.temperature(options);
end
