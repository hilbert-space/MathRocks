classdef Base < handle
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
  end

  properties (SetAccess = 'protected')
    %
    % The number of thermal nodes
    %
    nodeCount

    %
    % The leakage model
    %
    leakage
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.samplingInterval = options.samplingInterval;
      this.ambientTemperature = options.get( ...
        'ambientTemperature', Utils.toKelvin(45));

      if options.has('leakage')
        this.leakage = options.leakage;
      elseif options.has('leakageOptions')
        this.leakage = LeakagePower(options.leakageOptions);
      else
        this.leakage = [];
      end

      this.circuit = this.constructCircuit(options);
      this.processorCount = this.circuit.processorCount;
      this.nodeCount = this.circuit.nodeCount;
    end

    function [T, output] = compute(this, varargin)
      if isempty(this.leakage)
        [T, output] = this.computeWithoutLeakage(varargin{:});
      else
        [T, output] = this.computeWithLeakage(varargin{:});
      end
    end

    function string = toString(this)
      string = sprintf('%s(%s)', class(this), ...
        String(struct( ...
          'processorCount', this.processorCount, ...
          'nodeCount', this.nodeCount, ...
          'samplingInterval', this.samplingInterval, ...
          'ambientTemperature', this.ambientTemperature, ...
          'leakage', this.leakage)));
    end
  end

  methods (Abstract)
    [T, output] = computeWithoutLeakage(this, varargin)
    [T, output] = computeWithLeakage(this, varargin)
  end

  methods (Access = 'protected')
    function [parameters, sampleCount, temperatureIndex] = ...
      prepareParameters(this, parameters)

      if nargin < 2, parameters = struct; end
      parameters.T = NaN;

      %
      % NOTE: The parameters come as a structure whose fields are
      % m-by-n matrices, one for each leakage parameter. For each
      % matrix, the (i, j)th element corresponds to the ith sample
      % assigned to the jth processing element.
      %
      [parameters, dimensions, temperatureIndex] = this.leakage.assign( ...
        parameters, [NaN, this.processorCount]);

      %
      % For convenience, we would like to have n-by-m matrices instead.
      %
      parameters = cellfun(@transpose, parameters, 'UniformOutput', false);

      %
      % temperatureIndex is the position of the temperature parameter
      % among the leakage parameters.
      %
      assert(isscalar(temperatureIndex));

      sampleCount = dimensions(1);
    end
  end

  methods (Access = 'private')
    function circuit = constructCircuit(~, options)
      processorCount = options.processorCount;

      if ~File.exist(options.floorplan)
        error('The floorplan file does not exist.');
      end

      if ~File.exist(options.hotspotConfig)
        error('The configuration file does not exist.');
      end

      circuit = struct;
      circuit.processorCount = processorCount;
      circuit.nodeCount = 4 * processorCount + 12;

      [circuit.A, circuit.B, circuit.G, Gamb] = ...
        Utils.constructHotSpot(options.floorplan, options.hotspotConfig, ...
          options.get('hotspotLine', ''));

      circuit.Gamb = [zeros(3 * processorCount, 1); Gamb];

      assert(circuit.nodeCount == length(circuit.A));
      assert(circuit.nodeCount == length(circuit.Gamb));
    end
  end
end
