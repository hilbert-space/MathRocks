classdef HotSpot < handle
  properties (SetAccess = 'private')
    %
    % The number of thermal nodes
    %
    nodeCount

    %
    % The number of active nodes
    %
    processorCount

    %
    % The sampling interval
    %
    samplingInterval

    %
    % The ambient temperature
    %
    ambientTemperature

    %
    % The capacitance vector
    %
    capacitance

    %
    % The conductance matrix
    %
    conductance
  end

  methods
    function this = HotSpot(varargin)
      options = Options(varargin{:});

      if options.has('die')
        floorplan = options.die.filename;
      elseif options.has('floorplan');
        floorplan = options.floorplan;
      else
        assert(false);
      end

      config = options.config;
      line = options.get('line', '');

      if ~File.exist(floorplan)
        error('The floorplan file does not exist.');
      end

      if ~File.exist(config)
        error('The configuration file does not exist.');
      end

      [ this.capacitance, this.conductance, this.nodeCount, ...
        this.processorCount, this.samplingInterval, this.ambientTemperature ] = ...
        Temperature.HotSpot.constructModel(floorplan, config, line);
    end
  end

  methods (Abstract)
    T = compute(this, Pdyn, varargin)
  end

  methods (Static, Access = 'private')
    varargout = constructModel(varargin)
  end
end
