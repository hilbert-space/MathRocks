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

      P = combnk(1:size(I, 1), 2);

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

    function result = computeBasisCrossExpectation(this, I1, J1, I2, J2)
      [ II, K ] = sort([ I1(:), I2(:) ], 2);
      JJ = [ J1(:), J2(:) ];
      for i = 1:size(K, 1)
        JJ(i, :) = JJ(i, K(i, :));
      end

      [ IIJJ, ~, K ] = unique([ II, JJ ], 'rows');
      count = size(IIJJ, 1);

      [ IJ, ~, H ] = unique( ...
        [ IIJJ(:, 1), IIJJ(:, 3); IIJJ(:, 2), IIJJ(:, 4) ], 'rows');
      [ Yij, Mi, ~, L, R ] = this.computeNodes(IJ(:, 1), IJ(:, 2));

      function result_ = intOne(yij_, l_, r_)
        %
        % int_{l_}^{r_} (y - yij_) dy
        %
        result_ = (r_^2 - l_^2) / 2 - (r_ - l_) * yij_;
      end

      function result_ = intAbsOne(yij_, l_, r_)
        %
        % int_{l_}^{r_} |y - yij_| dy
        %
        if yij_ < l_
          result_ = intOne(yij_, l_, r_);
        elseif yij_ > r_
          result_ = - intOne(yij_, l_, r_);
        else
          result_ = - intOne(yij_, l_, yij_) + intOne(yij_, yij_, r_);
        end
      end

      function result_ = intTwo(yij1_, yij2_, l_, r_)
        %
        % int_{l_}^{r_} (y - yij1_) * (y - yij2_) dy
        %
        result_ = (r_^3 - l_^3) / 3 ...
          - (r_^2 - l_^2) * (yij1_ + yij2_) / 2 ...
          + (r_ - l_) * yij1_ * yij2_;
      end

      function result_ = intAbsTwo(yij1_, yij2_, l_, r_)
        %
        % int_{l_}^{r_} |y - yij1_| * |y - yij2_| dy
        %
        if yij1_ < l_
          if yij2_ < l_
            result_ = ...
              + intTwo(yij1_, yij2_, l_, r_);
          elseif yij2_ > r_
            result_ = ...
              - intTwo(yij1_, yij2_, l_, r_);
          else
            result_ = ...
              - intTwo(yij1_, yij2_, l_, yij2_) ...
              + intTwo(yij1_, yij2_, yij2_, r_);
          end
        elseif yij1_ > r_
          if yij2_ < l_
            result_ = ...
              - intTwo(yij1_, yij2_, l_, r_);
          elseif yij2_ > r_
            result_ = ...
              + intTwo(yij1_, yij2_, l_, r_);
          else
            result_ = ...
              + intTwo(yij1_, yij2_, l_, yij2_) ...
              - intTwo(yij1_, yij2_, yij2_, r_);
          end
        else
          if yij2_ < l_
            result_ = ...
              - intTwo(yij1_, yij2_, l_, yij1_) ...
              + intTwo(yij1_, yij2_, yij1_, r_);
          elseif yij2_ > r_
            result_ = ...
              + intTwo(yij1_, yij2_, l_, yij1_) ...
              - intTwo(yij1_, yij2_, yij1_, r_);
          else
            a = min(yij1_, yij2_);
            b = max(yij1_, yij2_);
            result_ = ...
              + intTwo(yij1_, yij2_, l_, a) ...
              - intTwo(yij1_, yij2_, a, b) ...
              + intTwo(yij1_, yij2_, b, r_);
          end
        end
      end

      result = zeros(count, 1);
      for k = 1:count
        i = H(k);
        j = H(k + count);

        if i == j
          if i == 1
            result(k) = 1;
          elseif i == 2
            result(k) = 1 / 6;
          else
            result(k) = 2.^(2 - i) / 3;
          end
          continue;
        end

        yij1 = Yij(i);
        yij2 = Yij(j);

        mi1 = Mi(i);
        mi2 = Mi(j);

        l = max(L(i), L(j));
        r = min(R(i), R(j));

        assert(l < r);

        if i == 1
          %
          % NOTE: Opposite!
          %
          result(k) = (r - l) ...
            - (mi2 - 1) * intAbsOne(yij2, l, r);
        elseif j == 1
          %
          % NOTE: Opposite!
          %
          result(k) = (r - l) ...
            - (mi1 - 1) * intAbsOne(yij1, l, r);
        else
          result(k) = (r - l) ...
            - (mi1 - 1) * intAbsOne(yij1, l, r) ...
            - (mi2 - 1) * intAbsOne(yij2, l, r) ...
            + (mi1 - 1) * (mi2 - 1) * intAbsTwo(yij1, yij2, l, r);
        end
      end

      result = prod(reshape(result(K), size(I1)), 2);
    end
  end
end
