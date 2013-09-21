function options = configure(varargin)
  options = Options(varargin{:});
  options.die = Die('floorplan', File.join('..', 'SystemSimulation', ...
    '+Test', 'Assets', sprintf('%03d.flp', options.processorCount)));
  options = Configure.processVariation(options);
end
