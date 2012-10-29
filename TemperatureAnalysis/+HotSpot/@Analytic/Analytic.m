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

    function T = compute(this, P, keepSteps)
      [ processorCount, stepCount ] = size(P);

      assert(processorCount == this.processorCount, ...
        'The power profile is invalid.')

      E = this.E;
      D = this.D;
      BT = this.BT;
      Tamb = this.ambientTemperature;

      if nargin < 3
        T = zeros(processorCount, stepCount);

        X = D * P(:, 1);
        T(:, 1) = BT * X + Tamb;

        for i = 2:stepCount
          X = E * X + D * P(:, i);
          T(:, i) = BT * X + Tamb;
        end
      else
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
    end
  end
end
