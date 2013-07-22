classdef HotSpot < handle
  properties (SetAccess = 'private')
    %
    % The thermal circuit by HotSpot:
    %
    %   diag(A) * dT / dt + B * (T - Tamb) = P
    %
    %   * A    - the capacitance vector,
    %   * B    - the coefficient matrix based on G and Gamb,
    %   * G    - the conductance matrix, and
    %   * Gamb - the conductance vector of the ambient nodes.
    %
    circuit

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
    % The leakage model
    %
    leakage
  end

  properties (SetAccess = 'protected')
    %
    % The number of thermal nodes
    %
    nodeCount
  end

  methods
    function this = HotSpot(varargin)
      options = Options(varargin{:});

      circuit = this.constructCircuit(options);

      if options.get('coarseCircuit', false)
        circuit = this.coarsen(circuit);
      end

      this.circuit = circuit;
      this.processorCount = circuit.processorCount;
      this.nodeCount = circuit.nodeCount;

      this.samplingInterval = options.samplingInterval;
      this.ambientTemperature = ...
        options.get('ambientTemperature', Utils.toKelvin(45));

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
    function circuit = constructCircuit(this, options)
      processorCount = options.processorCount;

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
      % NOTE: HotSpot v5.01 (and some earlier versions) is implied.
      %
      circuit = struct;
      circuit.processorCount = processorCount;
      circuit.nodeCount = 4 * processorCount + 12;

      [ circuit.A, circuit.B, circuit.G, Gamb ] = ...
        Utils.constructHotSpot(floorplan, config, line);

      circuit.Gamb = [ zeros(3 * processorCount, 1); Gamb ];

      assert(circuit.nodeCount == length(circuit.A));
      assert(circuit.nodeCount == length(circuit.Gamb));
    end

    function circuit = coarsen(this, circuit)
      processorCount = circuit.processorCount;

      %
      % Outter peripheral nodes of the heat sink
      %
      circuit = this.merge(circuit, ...
        (4 * processorCount + 4 + 4 + 1):(4 * processorCount + 4 + 4 + 4));

      %
      % Inner peripheral nodes of the heat sink
      %
      circuit = this.merge(circuit, ...
        (4 * processorCount + 4 + 1):(4 * processorCount + 4 + 4));

      %
      % Peripheral nodes of the heat spreader
      %
      circuit = this.merge(circuit, ...
        (4 * processorCount + 1):(4 * processorCount + 4));
    end

    function circuit = merge(this, circuit, I)
      circuit.A(end + 1) = sum(circuit.A(I));
      circuit.A(I) = [];

      J = setdiff(1:circuit.nodeCount, I);
      circuit.G = [ circuit.G(J, J), sum(circuit.G(J, I), 2);
        sum(circuit.G(I, J), 1), 0 ];

      circuit.Gamb(end + 1) = sum(circuit.Gamb(I));
      circuit.Gamb(I) = [];

      circuit.B = this.constructB(circuit.G, circuit.Gamb);
      circuit.nodeCount = length(circuit.A);
    end

    function B = constructB(this, G, Gamb)
      nodeCount = length(Gamb);
      B = -1 ./ (1 ./ G + 1 ./ G.') + diag(Gamb);
      for i = 1:nodeCount
        B(i, i) = sum([ B(i, i), -B(i, [ 1:(i - 1), (i + 1):nodeCount ]) ]);
      end
    end
  end

  methods (Static, Access = 'private')
    varargout = constructModel(varargin)
  end
end
