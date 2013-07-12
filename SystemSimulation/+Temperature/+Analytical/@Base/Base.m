classdef Base < Temperature.HotSpot
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
    % A = U * L * U^T
    %
    L
    U
    UT

    %
    % E = exp(A * t) = U * diag(exp(li * dt)) * U^T
    %
    E

    %
    % D = A^(-1) * (exp(A * t) - I) * B
    %   = U * diag((exp(li * t) - 1) / li) * U^T * B
    %
    D
  end

  methods
    function this = Base(varargin)
      this = this@Temperature.HotSpot(varargin{:});

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

      [ U, L ] = eig(this.A);

      this.L = diag(L);
      this.U = U;
      this.UT = U';

      this.E = this.U * diag(exp(dt * this.L)) * this.UT;
      this.D = this.U * diag((exp(dt * this.L) - 1) ./ this.L) * this.UT * B;
    end
  end
end
