classdef Hat < Basis.Base
  methods
    function this = Hat(varargin)
      this = this@Basis.Base(varargin{:});
    end
  end

  methods
    function result = evaluate(this, Y, I, J)
      basisCount = size(I, 1);
      pointCount = size(Y, 1);

      [ Yij, Mi, Li ] = this.computeNodes(I, J);

      K = abs(Y - Yij) < Li;

      result = zeros(pointCount, 1);
      if basisCount == 1
        result(K) = prod(1 - (Mi - 1) * abs(Y(K) - Yij), 2);
      else
        assert(basisCount == pointCount);
        result(K) = prod(1 - (Mi(K) - 1) * abs(Y(K) - Yij(K)), 2);
      end
    end

    function result = crossEvaluate(this, Y, I, J)
      [ basisCount, dimensionCount ] = size(I);
      pointCount = size(Y, 1);

      [ Yij, Mi, Li ] = this.computeNodes(I, J);

      result = zeros(basisCount, pointCount);
      delta = zeros(basisCount, dimensionCount);
      for i = 1:pointCount
        for j = 1:dimensionCount
          delta(:, j) = abs(Yij(:, j) - Y(i, j));
        end
        K = all(delta < Li, 2);

        result(K, i) = prod(1 - (Mi(K, :) - 1) .* delta(K, :), 2);
      end
    end

    function [ Yij, Mi, Li ] = computeNodes(~, I, J)
      Mi = 2.^(I - 1) + 1;
      Mi(I == 1) = 1;

      Li = 1 ./ (Mi - 1);
      Li(Mi == 1) = 1;

      Yij = (J - 1) ./ (Mi - 1);
      Yij(Mi == 1) = 0.5;
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
end
