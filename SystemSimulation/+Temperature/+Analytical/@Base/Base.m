classdef Base < Temperature.HotSpot
  properties (Access = 'protected')
    %
    % Original
    %
    %   Cth * dT/dt + Gth * (T - Tamb) = M * P
    %
    % Transformed
    %
    %   dX/dt = A * X + B * P
    %   T = C * X + D = B^T * X + Tamb
    %

    %
    % A = Cth^(-1/2) * (-Gth) * Cth^(-1/2)
    %
    A

    %
    % C = B^T = (Cth^(-1/2) * M)^T
    %
    C

    %
    % A = U * L * U^T
    %
    L
    U

    %
    % E = exp(A * dt) = U * diag(exp(li * dt)) * U^T
    %
    E

    %
    % F = A^(-1) * (exp(A * dt) - I) * B
    %   = U * diag((exp(li * dt) - 1) / li) * U^T * B
    %
    F
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this = this@Temperature.HotSpot(options);

      processorCount = this.processorCount;
      nodeCount = this.nodeCount;

      Cm12 = diag(sqrt(1 ./ this.circuit.A));

      A = Cm12 * (-this.circuit.B) * Cm12;
      A = triu(A) + transpose(triu(A, 1)); % ensure symmetry

      M = [ diag(ones(1, processorCount)); ...
        zeros(nodeCount - processorCount, processorCount) ];
      B = Cm12 * M;
      C = B';

      %
      % Preprocessing
      %
      [ A, B, C ] = this.processSystem(A, B, C, options);

      [ U, L ] = eig(A);
      L = diag(L);

      E = U * diag( exp(this.samplingInterval * L)          ) * U';
      F = U * diag((exp(this.samplingInterval * L) - 1) ./ L) * U' * B;

      this.nodeCount = length(L);

      this.A = A;
      this.C = C;
      this.L = L;
      this.U = U;
      this.E = E;
      this.F = F;
    end
  end

  methods (Access = 'protected')
    function [ A, B, C ] = processSystem(this, A, B, C, options)
      %
      % Model order reduction
      %
      [ A, B, C ] = Utils.reduceSystem(A, B, C, 0, ...
        options.get('reductionThreshold', 1), ...
        options.get('reductionLimit', 0));
    end
  end
end
