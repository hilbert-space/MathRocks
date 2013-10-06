classdef Hat < Basis.Base
  methods
    function this = Hat(varargin)
      this = this@Basis.Base(varargin{:});
    end
  end

  methods
    function aij = evaluate(~, y, i, j)
      if i == 1
        mi = 1;
      else
        mi = 2^(i - 1) + 1;
      end
      if mi == 1
        yij = 0.5;
      else
        yij = (j - 1) / (mi - 1);
      end
      aij = zeros(size(y));
      I = abs(y - yij) < 1 / (mi - 1);
      aij(I) = 1 - (mi - 1) * abs(y(I) - yij);
    end

    function I = index(~, i)
      switch i
      case 1
        I = 1;
      case 2
        I = [ 1 3 ];
      case 3
        I = [ 2 4 ];
      otherwise
        J = index(i - 1);
        I = [];
        for j = J
          I = [ I,  2 * j - 2, 2 * j ];
        end
      end
    end

    result = computeExpectation(this, i, j)
    result = computeSecondRawMoment(this, i, j)
    result = computeVariance(this, i, j)
    result = computeCovariance(this, i1, j1, i2, j2)

    result = deriveExpectation(this, i, j)
    result = deriveSecondRawMoment(this, i, j)
    result = deriveVariance(this, i, j)
    result = deriveCovariance(this, i1, j1, i2, j2)
  end
end
