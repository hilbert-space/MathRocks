classdef PhysicistHermite < PolynomialChaos.Base
  methods
    function this = PhysicistHermite(varargin)
      this = this@PolynomialChaos.Base(varargin{:}, ...
        'quadratureOptions', Options('rules', 'PhysicistGaussHermite'));
      this.distribution = ProbabilityDistribution.Normal();
    end
  end

  methods (Access = 'protected')
    function basis = constructUnivariateBasis(this, x, order)
      basis(1) = sympoly(1);

      for i = 2:(order + 1)
        basis(i) = 2 * x * basis(i - 1) - diff(basis(i - 1), x);
      end
    end

    function norm = computeNormalizationConstant(this, i, index)
      %
      % sqrt(2 * pi) is preserved.
      %
      index = index(i, :) - 1;
      norm = prod(2.^index .* factorial(index));
    end
  end
end
