classdef Uniform < ProbabilityTransformation.Gaussian
  methods
    function this = Uniform(varargin)
      this = this@ProbabilityTransformation.Gaussian(varargin{:});
    end

    function data = evaluate(this, data, ~)
      %
      % Independent standard Gaussian RVs.
      %
      data = this.gaussianDistribution.icdf(data);

      %
      % Dependent Gaussian RVs.
      %
      data = data * this.multiplier;

      %
      % Dependent uniform RVs.
      %
      data = this.gaussianDistribution.cdf(data);

      %
      % Dependent RVs with the desired distributions.
      %
      data = this.variables.icdf(data);
    end
  end

  methods (Access = 'protected')
    function [distribution, dimensionCount] = configure(this, options)
      [~, dimensionCount] = configure@ProbabilityTransformation.Gaussian(this, options);
      distribution = ProbabilityDistribution.Uniform;
    end
  end
end
