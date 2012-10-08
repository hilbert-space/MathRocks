classdef Base < handle
  properties (GetAccess = 'protected', SetAccess = 'private')
    %
    % The capacitance vector.
    %
    capacitance

    %
    % The conductance matrix.
    %
    conductance
  end

  properties (SetAccess = 'private')
    %
    % The number of thermal nodes in the thermal RC circuit.
    %
    nodeCount

    %
    % The number of active nodes, i.e., those that correspond to
    % the processing elements.
    %
    processorCount

    %
    % The sampling interval of the simulation.
    %
    samplingInterval

    %
    % The ambient temperature.
    %
    ambientTemperature
  end

  methods
    function this = Base(floorplanFilename, configFilename, configLine)
      if nargin < 3, configLine = ''; end

      if ~File.exist(floorplanFilename)
        error('The floorplan file does not exist.');
      end

      if ~File.exist(configFilename)
        error('The configuration file does not exist.');
      end

      [ this.capacitance, this.conductance, this.nodeCount, ...
        this.processorCount, this.samplingInterval, this.ambientTemperature ] = ...
        HotSpot.constructModel(floorplanFilename, configFilename, configLine);
    end
  end

  methods (Abstract)
    temperatureProfile = compute(this, powerProfile)
  end
end
