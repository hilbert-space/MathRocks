classdef Base < Temperature.HotSpot
  properties (Access = 'protected')
    %
    % Original
    %
    %   Cth * dZ/dt + Gth * Z = M * P
    %   T = M^T * Z + Tamb
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
      % Model order reduction
      %
      reductionThreshold = options.get('reductionThreshold', 1);
      reductionLimit = options.get('reductionLimit', 0);
      if reductionThreshold < 1 && reductionLimit < 1
        [ A, B, C ] = this.approximate(A, B, C, 0, ...
          reductionThreshold, reductionLimit);
        nodeCount = size(A, 1);
        this.nodeCount = nodeCount;
      end

      [ U, L ] = eig(A);
      L = diag(L);

      E = U * diag( exp(this.samplingInterval * L)          ) * U';
      F = U * diag((exp(this.samplingInterval * L) - 1) ./ L) * U' * B;

      this.A = A;
      this.C = C;
      this.L = L;
      this.U = U;
      this.E = E;
      this.F = F;
    end
  end

  methods (Access = 'protected')
    function [ A, B, C, D ] = approximate(this, A, B, C, D, ...
      reductionThreshold, reductionLimit)

      s = ss(A, B, C, D);

      [ L, baldata ] = hsvd(s);

      nodeCount = size(A, 1);
      nodeCount = max(Utils.chooseSignificant( ...
        L, reductionThreshold), floor(nodeCount * reductionLimit));

      r = balred(s, nodeCount, 'Elimination', 'Truncate', ...
        'Balancing', baldata);

      A = r.a;
      B = r.b;
      C = r.c;
      D = r.d;
    end
  end
end
