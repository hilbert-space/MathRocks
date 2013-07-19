classdef HotSpot < handle
  properties (SetAccess = 'private')
    %
    % The number of active nodes
    %
    processorCount

    %
    % The number of thermal nodes
    %
    nodeCount

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

    %
    % The leakage model
    %
    leakage
  end

  methods
    function this = HotSpot(varargin)
      options = Options(varargin{:});

      if options.has('die')
        floorplan = options.die.filename;
      else
        floorplan = options.floorplan;
      end

      if ~File.exist(floorplan)
        error('The floorplan file does not exist.');
      end

      config = options.hotspotConfiguration;

      if ~File.exist(config)
        error('The configuration file does not exist.');
      end

      line = options.get('hotspotLine', '');

      %
      % Thermal model
      %
      [ this.capacitance, this.conductance ] = ...
        Utils.constructHotSpot(floorplan, config, line);

      this.processorCount = options.processorCount;
      this.nodeCount = length(this.capacitance);

      %
      % NOTE: HotSpot v5.01 (and some earlier versions) is implied.
      %
      assert(4 * this.processorCount + 12 == this.nodeCount);

      this.samplingInterval = options.samplingInterval;
      this.ambientTemperature = ...
        options.get('ambientTemperature', Utils.toKelvin(45));

      if options.get('coarseHotSpot', false), this.coarsen; end

      %
      % Leakage model
      %
      if options.has('leakage')
        this.leakage = options.leakage;
      else
        this.leakage = LeakagePower.(options.leakageModel)( ...
          options.leakageOptions);
      end
    end

    function [ T, output ] = compute(this, Pdyn, varargin)
      [ T, output ] = this.solve(Pdyn, Options(varargin{:}));
    end

    function display(this)
      fprintf('%s:\n', class(this));
      fprintf('  Processing elements: %d\n', this.processorCount);
      fprintf('  Thermal nodes:       %d\n', this.nodeCount);
      fprintf('  Sampling interval:   %.2e s\n', this.samplingInterval);
      fprintf('  Ambient temperature: %.2f C\n', ...
        Utils.toCelsius(this.ambientTemperature));

      if isempty(this.leakage), return; end

      fprintf('  Leakage model:       %s\n', class(this.leakage));
    end

    function string = toString(this)
      string = sprintf('%s(%d, %d, %.2e, %.2f, %s)', ...
        class(this), this.processorCount, this.nodeCount, ...
        this.samplingInterval, this.ambientTemperature, ...
        Utils.toString(this.leakage));
    end
  end

  methods (Abstract)
    [ T, output ] = solve(this, Pdyn, options)
  end

  methods (Access = 'private')
    function coarsen(this)
      processorCount = this.processorCount;
      nodeCount = this.nodeCount;

      Cold = this.capacitance;
      Gold = this.conductance;

      %
      % Processing elements
      %

      %
      % Thermal interface material
      %

      %
      % Heat spreader
      %

      %
      % Heat sink
      %
      I = [ (3 * processorCount + 1):(4 * processorCount), ...
        (4 * processorCount + 4 + 1):(4 * processorCount + 4 + 8) ];
      J = setdiff(1:nodeCount, I);

      Cnew = Cold(J);
      Cnew(end + 1) = sum(Cold(I));

      Gnew = Gold(J, J);
      Gnew(end + 1, end + 1) = sum(diag(Gold(I, I)));
      for i = 1:length(I)
        Gnew(end, 1:(end - 1)) = Gnew(end, 1:(end - 1)) + Gold(I(i), J);
        Gnew(1:(end - 1), end) = Gnew(1:(end - 1), end) + Gold(J, I(i));
      end

      this.nodeCount = length(Cnew);
      this.capacitance = Cnew;
      this.conductance = Gnew;
    end
  end

  methods (Static, Access = 'private')
    varargout = constructModel(varargin)
  end
end
