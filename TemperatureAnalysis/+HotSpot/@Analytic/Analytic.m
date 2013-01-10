classdef Analytic < HotSpot.Base
  properties (Access = 'protected')
    %
    % Original system:
    %
    %   C * dZ/dt + G * Z = M * P
    %   T = M^T * Z + T_amb
    %
    % Transformed system:
    %
    %   dX/dt = A * X + B * P
    %   T = B^T * X + T_amb
    %

    %
    % C^(-1/2)
    %
    Cm12

    %
    % A = C^(-1/2) * (-G) * C^(-1/2)
    %
    A

    %
    % B^T = (C^(-1/2) * M)^T
    %
    BT

    %
    % Eigenvalue decomposition of Gt
    % A = Q * L * Q^T
    %
    L
    Q
    QT

    %
    % E = exp(A * t) = Q * diag(exp(li * dt)) * Q^T
    %
    E

    %
    % D = A^(-1) * (exp(A * t) - I) * B
    %   = Q * diag((exp(li * t) - 1) / li) * Q^T * B
    %
    D
  end

  methods
    function this = Analytic(varargin)
      this = this@HotSpot.Base(varargin{:});

      nodeCount = this.nodeCount;
      processorCount = this.processorCount;
      dt = this.samplingInterval;

      this.Cm12 = diag(sqrt(1 ./ this.capacitance));

      M = [ diag(ones(1, processorCount)); ...
        zeros(nodeCount - processorCount, processorCount) ];

      %
      % Make sure that the matrix A is symmetric.
      %
      A = this.Cm12 * (-this.conductance) * this.Cm12;
      this.A = triu(A) + transpose(triu(A, 1));

      B = this.Cm12 * M;
      this.BT = B';

      [ Q, L ] = eig(this.A);

      this.L = diag(L);
      this.Q = Q;
      this.QT = Q';

      this.E = this.Q * diag(exp(dt * this.L)) * this.QT;
      this.D = this.Q * diag((exp(dt * this.L) - 1) ./ this.L) * this.QT * B;
    end

    function [ T, Pleak ] = compute(this, Pdyn, varargin)
      if nargin == 2
        T = this.computeRegular(Pdyn);
      elseif isa(varargin{1}, 'double')
        T = this.computeSparse(Pdyn, varargin{:});
      elseif isa(varargin{1}, 'LeakagePower')
        [ T, Pleak ] = this.computeWithLeakage(Pdyn, varargin{:});
      else
        assert(false);
      end
    end
  end

  methods (Access = 'protected')
    function T = computeRegular(this, P)
      [ processorCount, stepCount ] = size(P);
      assert(processorCount == this.processorCount);

      E = this.E;
      D = this.D;
      BT = this.BT;
      Tamb = this.ambientTemperature;

      T = zeros(processorCount, stepCount);

      X = D * P(:, 1);
      T(:, 1) = BT * X + Tamb;

      for i = 2:stepCount
        X = E * X + D * P(:, i);
        T(:, i) = BT * X + Tamb;
      end
    end

    function T = computeSparse(this, P, keepSteps)
      [ processorCount, stepCount ] = size(P);
      assert(processorCount == this.processorCount);

      E = this.E;
      D = this.D;
      BT = this.BT;
      Tamb = this.ambientTemperature;

      %
      % NOTE: It is assumed that `keepSteps' is sorted
      % in the ascending order.
      %
      keepStepCount = length(keepSteps);
      k = 1;

      T = zeros(processorCount, keepStepCount);

      X = D * P(:, 1);
      if keepSteps(k) == 1
        T(:, k) = BT * X + Tamb;
        k = k + 1;
      end

      for i = 2:stepCount
        X = E * X + D * P(:, i);
        if keepSteps(k) == i
          T(:, k) = BT * X + Tamb;
          k = k + 1;
          if k > keepStepCount, return; end
        end
      end
    end

    function [ T, Pleak ] = computeWithLeakage(this, Pdyn, leakage, L)
      [ processorCount, stepCount ] = size(Pdyn);
      assert(processorCount == this.processorCount);

      if nargin < 4, L = leakage.Lnom; end

      E = this.E;
      D = this.D;
      BT = this.BT;
      Tamb = this.ambientTemperature;

      T = zeros(processorCount, stepCount);
      Pleak = zeros(processorCount, stepCount);

      Pleak(:, 1) = leakage.evaluate(L, Tamb);
      X = D * (Pdyn(:, 1) + Pleak(:, 1));
      T(:, 1) = BT * X + Tamb;

      for i = 2:stepCount
        Pleak(:, i) = leakage.evaluate(L, T(:, i - 1));
        X = E * X + D * (Pdyn(:, i) + Pleak(:, i));
        T(:, i) = BT * X + Tamb;
      end
    end
  end
end
