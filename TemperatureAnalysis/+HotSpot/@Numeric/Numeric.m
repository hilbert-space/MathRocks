classdef Numeric < HotSpot.Base
  properties (Access = 'private')
    At
    Bt
  end

  methods
    function this = Numeric(varargin)
      this = this@HotSpot.Base(varargin{:});

      nodeCount = this.nodeCount;
      processorCount = this.processorCount;

      M = [ diag(ones(1, processorCount)); ...
        zeros(nodeCount - processorCount, processorCount) ];

      Cm1 = diag(1 ./ this.capacitance);

      this.At = - Cm1 * this.conductance;
      this.Bt = Cm1 * M;
    end

    function T = compute(this, P, keepSteps)
      [ processorCount, stepCount ] = size(P);

      assert(processorCount == this.processorCount, ...
        'The power profile is invalid.')

      if nargin < 3, keepSteps = 1:stepCount; end

      At = this.At;
      Bt = this.Bt;
      dt = this.samplingInterval;
      Tamb = this.ambientTemperature;

      function Tt = solve(t, Tt)
        a = floor(t / dt);
        b = t / dt - a; c = 1 - b;
        i = min(stepCount, 1 + a);
        j = min(stepCount, 2 + a);
        Tt = At * (Tt - Tamb) + Bt * (c * P(:, i) + b * P(:, j));
      end

      timeSpan = dt * [ 0 keepSteps ];
      T0 = ones(1, this.nodeCount) * Tamb;

      [ ~, T ] = ode45(@solve, timeSpan, T0);
      T = transpose(T(2:end, 1:processorCount));
    end
  end
end
