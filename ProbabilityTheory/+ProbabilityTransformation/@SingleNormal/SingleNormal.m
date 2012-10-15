classdef SingleNormal < ProbabilityTransformation.Base
  properties (Access = 'private')
    normal
  end

  methods
    function this = SingleNormal(varargin)
      this = this@ProbabilityTransformation.Base(varargin{:});
    end

    function data = sample(this, samples)
      %
      % Normal RV.
      %
      data = this.normal.sample(samples, 1);

      %
      % The RV with the desired distribution.
      %
      data = this.evaluateNative(data);
    end

    function data = evaluateNative(this, data)
      %
      % Uniform RV.
      %
      data = this.normal.apply(data);

      %
      % The RV with the desired distribution.
      %
      data = this.variables.invert(data);
    end

    function data = evaluateUniform(this, data)
      %
      % Independent normal RVs.
      %
      data = this.normal.invert(data);

      %
      % Dependent RVs with the desired distributions.
      %
      data = this.evaluateNative(data);
    end
  end

  methods (Access = 'protected')
    function initialize(this, variable, options)
      this.normal = ProbabilityDistribution.Normal();
      initialize@ProbabilityTransformation.Base(this, variable, options);
    end
  end
end
