classdef Hat < Basis.Base
  methods
    function this = Hat(varargin)
      this = this@Basis.Base(varargin{:}, 'support', [ 0, 1 ]);
    end
  end

  methods
    function result = evaluate(this, I, J, Y)
      basisCount = size(I, 1);
      pointCount = size(Y, 1);

      [ Yij, Mi, Li ] = this.computeNodes(I, J);

      result = zeros(basisCount, pointCount);

      for i = 1:pointCount
        delta = abs(bsxfun(@minus, Yij, Y(i, :)));
        K = all(delta < Li, 2);
        result(K, i) = prod(1 - (Mi(K, :) - 1) .* delta(K, :), 2);
      end
    end

    function result = computeExpectation(this, I, ~, C)
      result = sum(bsxfun(@times, C, ...
        this.computeBasisExpectation(I)), 1);
    end

    function result = computeVariance(this, I, J, C)
      expectation = this.computeBasisExpectation(I);

      result1 = sum(bsxfun(@times, C.^2, ...
        this.computeBasisSecondRawMoment(I) - expectation.^2), 1);

      P = combinator(size(I, 1), 2, 'c', 'n');

      [ ~, ~, ~, L, R ] = this.computeNodes(I, J);

      Z = all( ...
        max(L(P(:, 1), :), L(P(:, 2), :)) < ...
        min(R(P(:, 1), :), R(P(:, 2), :)), 2);

      result2 = (-1) * expectation(P(:, 1)) .* expectation(P(:, 2));
      result2(Z) = result2(Z) + this.computeBasisCrossExpectation( ...
          I(P(Z, 1), :), J(P(Z, 1), :), I(P(Z, 2), :), J(P(Z, 2), :));
      result2 = sum(bsxfun(@times, C(P(:, 1), :) .* C(P(:, 2), :), result2), 1);

      result = result1 + 2 * result2;
    end

    function [ Yij, Mi, Li, L, R ] = computeNodes(~, I, J)
      Mi = 2.^(I - 1) + 1;
      Mi(I == 1) = 1;

      Li = 1 ./ (Mi - 1);
      Li(Mi == 1) = 1;

      Yij = (J - 1) .* Li;
      Yij(Mi == 1) = 0.5;

      if nargout < 4, return; end

      L = max(0, Yij - Li);

      if nargout < 5, return; end

      R = min(1, Yij + Li);
    end

    function J = computeLevelOrders(this, i)
      switch i
      case 1
        J = 1;
      case 2
        J = [ 1; 3 ];
      case 3
        J = [ 2; 4 ];
      otherwise
        J = this.computeLevelOrders(i - 1);
        J = [ 2 * J - 2; 2 * J ];
      end
    end

    function J = computeChildOrders(~, i, j)
      switch i
      case 1
        assert(j == 1);
        J = [ 1; 3 ];
      case 2
        if j == 1
          J = 2;
        else
          assert(j == 3);
          J = 4;
        end
      otherwise
        J = [ 2 * j - 2; 2 * j ];
      end
    end
  end

  methods (Access = 'private')
    function result = computeBasisExpectation(~, I)
      [ I, ~, K ] = unique(I, 'rows');
      result = 2.^(1 - I);
      result(I == 1) = 1;
      result(I == 2) = 1 / 4;
      result = prod(result, 2);
      result = result(K);
    end

    function result = computeBasisSecondRawMoment(~, I)
      [ I, ~, K ] = unique(I, 'rows');
      result = 2.^(2 - I) / 3;
      result(I == 1) = 1;
      result(I == 2) = 1 / 6;
      result = prod(result, 2);
      result = result(K);
    end
  end
end
