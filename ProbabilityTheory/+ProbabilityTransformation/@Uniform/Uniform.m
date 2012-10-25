classdef Uniform < ProbabilityTransformation.Base
  methods
    function this = Uniform(varargin)
      this = this@ProbabilityTransformation.Base(varargin{:});
    end

    function data = sample(this, samples)
      %
      % Independent uniform RVs.
      %
      data = this.distribution.sample(samples, this.dimension);

      %
      % Independent RVs with the desired distributions.
      %
      data = this.evaluate(data);
    end

    function data = evaluate(this, data)
      %
      % Independent RVs with the desired distributions.
      %
      data = this.variables.invert(data);
    end
  end

  methods (Access = 'protected')
    function initialize(this, variables, options)
      initialize@ProbabilityTransformation.Base(this, variables, options);

      this.distribution = ProbabilityDistribution.Beta( ...
        'alpha', 1, 'beta', 1, 'a', 0, 'b', 1);

      assert(variables.isIndependent(), ...
        'Only independent random variables are supported.');
    end
  end
end
