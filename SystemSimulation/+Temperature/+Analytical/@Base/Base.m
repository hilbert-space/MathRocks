classdef Base < Temperature.HotSpot
  properties (Access = 'protected')
    %
    % Original system:
    %
    %   C * dZ/dt + G * Z = M * P
    %   T = M^T * Z + Tamb
    %
    % Transformed system:
    %
    %   dX/dt = A * X + B * P
    %   T = B^T * X + Tamb
    %

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
      BT = B';

      preserveCount = floor(options.get('modelReduction', 1) * nodeCount);
      if preserveCount < nodeCount
        s = ss(A, B, BT, 0);

        [ ~, baldata ] = hsvd(s);
        r = balred(s, preserveCount, 'Balancing', baldata);

        % [ ~, gain ] = balreal(s);
        % count = max(processorCount, ...
        %   Utils.chooseSignificant(gain, options.modelReduction));
        % r = modred(s, (count + 1):nodeCount);

        A = r.a;
        B = r.b;
        BT = r.c;

        this.nodeCount = size(A, 1);
      end

      [ U, L ] = eig(A);
      L = diag(L);
      UT = U';

      E = U * diag(exp(this.samplingInterval * L)) * UT;
      D = U * diag((exp(this.samplingInterval * L) - 1) ./ L) * UT * B;

      this.A  = A;
      this.BT = BT;
      this.L  = L;
      this.U  = U;
      this.UT = UT;
      this.E  = E;
      this.D  = D;
    end
  end
end
