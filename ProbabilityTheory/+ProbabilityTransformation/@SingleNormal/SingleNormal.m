classdef SingleNormal < ProbabilityTransformation.Base
  methods
    function this = SingleNormal(varargin)
      this = this@ProbabilityTransformation.Base(varargin{:});
    end

    function data = sample(this, samples)
      %
      % Normal RV.
      %
      data = this.distribution.sample(samples, 1);

      %
      % The RV with the desired distribution.
      %
      data = this.evaluate(data);
    end

    function data = evaluate(this, data)
      %
      % Uniform RV.
      %
      data = this.distribution.apply(data);

      %
      % The RV with the desired distribution.
      %
      data = this.variables.invert(data);
    end
  end

  methods (Access = 'protected')
    function initialize(this, variable, options)
      initialize@ProbabilityTransformation.Base(this, variable, options);
      this.distribution = ProbabilityDistribution.Normal();
    end
  end
end
