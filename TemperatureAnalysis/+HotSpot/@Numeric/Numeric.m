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

    function T = compute(this, P)
      [ processorCount, stepCount ] = size(P);
      assert(processorCount == this.processorCount);

      At = this.At;
      Bt = this.Bt;
      dt = this.samplingInterval;
      Tamb = this.ambientTemperature;

      T = zeros(stepCount, processorCount);
      T0 = Tamb * ones(1, this.nodeCount);

      for i = 1:stepCount
        [ ~, T0 ] = ode45(@(t, Tt) ...
          At * (Tt - Tamb) + Bt * P(:, i), [ 0, dt ], T0);

        T0 = T0(end, :);
        T(i, :) = T0(1:processorCount);
      end

      T = transpose(T);
    end

    function [ T, Pleak ] = computeWithLeakage(this, Pdyn, leakage)
      [ processorCount, stepCount ] = size(Pdyn);
      assert(processorCount == this.processorCount);

      At = this.At;
      Bt = this.Bt;
      dt = this.samplingInterval;
      Tamb = this.ambientTemperature;
      L = leakage.Lnom;

      T = zeros(stepCount, processorCount);
      Pleak = zeros(stepCount, processorCount);

      T0 = Tamb * ones(1, this.nodeCount);

      for i = 1:stepCount
        [ ~, T0 ] = ode45(@(t, Tt) ...
          At * (Tt - Tamb) + ...
          Bt * (Pdyn(:, i) + leakage.evaluate(L, Tt(1:processorCount))), ...
          [ 0, dt ], T0);

        T0 = T0(end, :);

        T(i, :) = T0(1:processorCount);
        Pleak(i, :) = leakage.evaluate(L, T(i, :));
      end

      T = transpose(T);
      Pleak = transpose(Pleak);
    end
  end
end
