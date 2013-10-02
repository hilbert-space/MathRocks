classdef Custom < ProbabilityTransformation.Gaussian
  properties (SetAccess = 'private')
    customDistribution
  end

  methods
    function this = Custom(varargin)
      this = this@ProbabilityTransformation.Gaussian(varargin{:});
    end

    function data = evaluate(this, data, isUniform)
      if nargin < 3 || ~isUniform
        %
        % Independent uniform RVs.
        %
        data = this.customDistribution.cdf(data);
      end

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
    function [ distribution, dimensionCount ] = configure(this, options)
      [ ~, dimensionCount ] = ...
        configure@ProbabilityTransformation.Gaussian(this, options);

      this.customDistribution = options.distribution;
      distribution = this.customDistribution;
    end
  end
end
