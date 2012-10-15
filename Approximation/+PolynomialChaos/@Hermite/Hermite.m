classdef Hermite < PolynomialChaos.Base
  methods
    function this = Hermite(varargin)
      this = this@PolynomialChaos.Base(varargin{:});
      this.distribution = ProbabilityDistribution.Normal();
    end
  end

  methods (Access = 'protected')
    function basis = constructUnivariateBasis(this, x, order)
      basis(1) = sympoly(1);

      for i = 2:(order + 1)
        basis(i) = x * basis(i - 1) - diff(basis(i - 1), x);
      end
    end

    function norm = computeNormalizationConstant(this, i, index)
      norm = prod(factorial(index(i, :) - 1));
    end
  end
end
