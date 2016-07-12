classdef Base < Temperature.Base
  properties (Access = 'protected')
    %
    % The original system is
    %
    %   Cth * dQth / dt + Gth * (Qth - Qamb) = M * P
    %   Q = M^T * Qth
    %
    % where Qth is the temperature of all the thermal node
    % while Q is the temperature of those that represent
    % processing elements.
    %
    % The transformed system is
    %
    %   dX / dt = A * X + B * P
    %   Q = C * X + Qamb
    %
    % where
    %
    %   X = Cth^(1/2) * (Qth - Qamb),
    %   A = Cth^(-1/2) * (-Gth) * Cth^(-1/2),
    %   B = Cth^(-1/2) * M, and
    %   C = B^T.
    %
    A
    B
    C

    %
    % NOTE: If the model order reduction is turned on,
    % the system becomes
    %
    %   dX / dt = A * X + B * P
    %   Q = C * X + D * P + Qamb
    %
    % where D is generally a non-zero matrix, and the other
    % coefficient matrices get altered.
    %
    D

    %
    % The eigenvalue decomposition of A:
    %
    %   A = U * L * U^(-1) = U * L * V
    %
    L
    U
    V

    %
    % The solution of the system for a short time interval
    % [ 0, t ] is based on the following recurrence:
    %
    %   X(t) = E * X(0) + F * P(0).
    %
    % The first coefficient of the recurrence:
    %
    %   E = exp(A * dt) = U * diag(exp(li * dt)) * V
    %
    %
    % The second coefficient of the recurrence:
    %
    %   F = A^(-1) * (exp(A * dt) - I) * B
    %     = U * diag((exp(li * dt) - 1) / li) * V * B
    %
    E
    F
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Base(options);

      processorCount = this.processorCount;
      nodeCount = this.nodeCount;

      Cth = this.circuit.A;
      Gth = this.circuit.B;

      M = [ diag(ones(1, processorCount)); ...
        zeros(nodeCount - processorCount, processorCount) ];

      T = diag(sqrt(1 ./ Cth));

      A = T * (-Gth) * T;
      A = triu(A) + transpose(triu(A, 1)); % ensure symmetry

      B = T * M;
      C = transpose(B);
      D = 0;

      %
      % Model order reduction
      %
      if ~isempty(options.get('modelOrderReduction', []))
        [ A, B, C, D ] = Utils.reduceModelOrder( ...
          A, B, C, D, options.modelOrderReduction);

        %
        % NOTE: A is not necessarily a symmetric matrix; hence,
        % the eigenvectors might not be orthogonal.
        %
        [ U, L ] = eig(A);
        V = inv(U);
        L = diag(L);

        if any(~isreal(L))
          warning('Detected eigenvalues with non-zero imaginary parts.');
          L = real(L);
          U = real(U);
          V = real(V);
        end

        assert(all(L < 0));
      else
        [ U, L ] = eig(A);
        V = transpose(U); % due to the symmetry
        L = diag(L);
      end

      E = U * diag(exp(this.samplingInterval * L)) * V;
      F = U * diag((exp(this.samplingInterval * L) - 1) ./ L) * V * B;

      this.nodeCount = length(L);

      this.A = A;
      this.B = B;
      this.C = C;
      this.D = D;
      this.L = L;
      this.U = U;
      this.V = V;
      this.E = E;
      this.F = F;
    end
  end
end
