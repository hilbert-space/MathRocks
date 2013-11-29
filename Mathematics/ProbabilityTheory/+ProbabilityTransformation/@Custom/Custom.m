classdef Custom < ProbabilityTransformation.Uniform
  properties (SetAccess = 'private')
    customDistribution
  end

  methods
    function this = Custom(varargin)
      this = this@ProbabilityTransformation.Uniform(varargin{:});
    end

    function data = evaluate(this, data, isUniform)
      if nargin < 3 || ~isUniform
        %
        % Independent uniform RVs.
        %
        data = this.customDistribution.cdf(data);
      end

      data = evaluate@ProbabilityTransformation.Uniform(this, data);
    end
  end

  methods (Access = 'protected')
    function [ distribution, dimensionCount ] = configure(this, options)
      [ ~, dimensionCount ] = configure@ProbabilityTransformation.Uniform(this, options);
      distribution = options.distribution;
      this.customDistribution = distribution;
    end
  end
end
