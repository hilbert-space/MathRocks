classdef Base < Temperature.Base
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
      this = this@Temperature.Base(options);

      processorCount = this.processorCount;
      nodeCount = this.nodeCount;

      Cth = this.circuit.A;
      Gth = this.circuit.B;

      M = [ diag(ones(1, processorCount)); ...
        zeros(nodeCount - processorCount, processorCount) ];

      %
      % Leakage linearization
      %
      if ~isempty(options.get('linearizeLeakage', []))
        alpha = this.leakage.linearize( ...
          options.linearizeLeakage, 'target', 'T', ...
          'compose', @(alpha, beta) this.Tamb * alpha + beta);
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
      if ~isempty(options.get('reduceModelOrder', []))
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

    function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
      if this.leakage.isLinearized
        [ T, output ] = this.computeWithLinearLeakage(Pdyn, varargin{:});
      else
        [ T, output ] = this.computeWithNonlinearLeakage(Pdyn, varargin{:});
      end
    end
  end

  methods (Abstract)
    [ T, output ] = computeWithLinearLeakage(this, Pdyn, varargin)
    [ T, output ] = computeWithNonlinearLeakage(this, Pdyn, varargin)
  end
end
