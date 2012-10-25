classdef Beta < ProbabilityDistribution.Base
  properties (SetAccess = 'private')
    alpha
    beta
    a
    b
  end

  methods
    function this = Beta(varargin)
      this = this@ProbabilityDistribution.Base()

      options = Options( ...
        'alpha', 1, 'beta', 1, 'a', 0, 'b', 1, varargin{:});

      this.alpha = options.alpha;
      this.beta = options.beta;
      this.a = options.a;
      this.b = options.b;

      this.expectation = this.alpha / (this.alpha + this.beta);
      this.expectation = this.expectation * (this.b - this.a) + this.a;

      this.variance = this.alpha * this.beta / ...
        (this.alpha + this.beta)^2 / ...
        (this.alpha + this.beta + 1);
      this.variance = this.variance * (this.b - this.a)^2;

      this.support = [ this.a, this. b ];
    end

    function data = sample(this, samples, dimension)
      data = betarnd(this.alpha, this.beta, samples, dimension);
      data = data * (this.b - this.a) + this.a;
    end

    function data = apply(this, data)
      data = (data - this.a) / (this.b - this.a);
      data = betacdf(data, this.alpha, this.beta);
    end

    function data = invert(this, data)
      data = betainv(data, this.alpha, this.beta);
      data = data * (this.b - this.a) + this.a;
    end
  end
end
