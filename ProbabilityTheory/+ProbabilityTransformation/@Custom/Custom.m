classdef Custom < ProbabilityTransformation.Gaussian
  properties (SetAccess = 'private')
    customDistribution
  end

  methods
    function this = Custom(varargin)
      this = this@ProbabilityTransformation.Gaussian(varargin{:});
    end

    function data = sample(this, sampleCount)
      %
      % Independent RVs of the specified custom distribution.
      %
      data = this.customDistribution.sample( ...
        sampleCount, this.dimensionCount);

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
      % Independent standard Gaussian RVs.
      %
      data = this.gaussianDistribution.icdf(data);

      %
      % Dependent RVs with the desired distributions.
      %
      data = evaluate@ProbabilityTransformation.Gaussian(this, data);
    end
  end

  methods (Access = 'protected')
    function [ distribution, dimensionCount ] = configure(this, options)
      [ ~, dimensionCount ] = ...
        configure@ProbabilityTransformation.Gaussian(this, options);

      this.customDistribution = options.distribution;
      distribution = this.customDistribution;
    end
  end
end
