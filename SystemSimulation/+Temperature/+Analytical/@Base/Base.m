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

      Cth = this.circuit.A;
      Gth = this.circuit.B;

      M = [ diag(ones(1, processorCount)); ...
        zeros(nodeCount - processorCount, processorCount) ];

      %
      % Leakage linearization
      %
      if options.has('linearizeLeakage')
        [ ~, alpha, beta ] = Utils.linearizeLeakage(this.leakage, ...
          'TRange', [ this.Tamb, this.leakage.Tref ], options.linearizeLeakage);

        leakage = struct;
        leakage.Vnom = this.leakage.Vnom;
        leakage.compute = @(V, T) this.Tamb * alpha + beta(V);
        this.leakage = leakage;

        Gth = Gth - M * alpha * eye(processorCount) * M';
      end

      T = diag(sqrt(1 ./ Cth));

      A = T * (-Gth) * T;
      A = triu(A) + transpose(triu(A, 1)); % ensure symmetry

      B = T * M;
      C = B';

      %
      % Model order reduction
      %
      if options.has('reduceModelOrder')
        [ A, B, C ] = Utils.reduceModelOrder(A, B, C, 0, ...
          options.reduceModelOrder);
      end

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

    function [ T, output ] = compute(this, Pdyn, varargin)
      if isa(this.leakage, 'struct')
        [ T, output ] = computeWithLeakage(this, Pdyn, ...
          Options(varargin{:}, 'iterationLimit', 1));
        output.P = 0; % to be fixed is needed
      else
        [ T, output ] = compute@Temperature.HotSpot(this, Pdyn, ...
          varargin{:});
      end
    end
  end
end
