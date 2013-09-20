classdef Custom < ProbabilityTransformation.Gaussian
  properties (SetAccess = 'protected')
    customDistribution
  end

  methods
    function this = Custom(varargin)
      options = Options(varargin{:});
      this = this@ProbabilityTransformation.Gaussian(options);
      this.customDistribution = options.distribution;
    end

    function data = sample(this, sampleCount)
      %
      % Independent RVs of the specified custom distribution.
      %
      data = this.customDistribution.sample(sampleCount, this.dimensionCount);

      %
      % Dependent RVs with the desired distributions.
      %
      data = this.evaluate(data);
    end

    function data = evaluate(this, data)
      %
      % Independent uniform RVs.
      %
      data = this.customDistribution.cdf(data);

      %
      % Independent standard normal RVs.
      %
      data = this.distribution.icdf(data);

      %
      % Dependent RVs with the desired distributions.
      %
      data = evaluate@ProbabilityTransformation.Gaussian(this, data);
    end
  end
end
