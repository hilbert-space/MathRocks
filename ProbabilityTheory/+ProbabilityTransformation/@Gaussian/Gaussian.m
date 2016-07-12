classdef Gaussian < ProbabilityTransformation.Base
  properties (SetAccess = 'private')
    gaussianDistribution
    multiplier
    importance
  end

  methods
    function this = Gaussian(varargin)
      this = this@ProbabilityTransformation.Base(varargin{:});
    end

    function data = sample(this, sampleCount)
      %
      % Independent Gaussian RVs.
      %
      data = this.gaussianDistribution.sample( ...
        sampleCount, this.dimensionCount);

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

    function data = evaluate(this, data, isUniform)
      if nargin > 2 && isUniform
        %
        % Independent Gaussian RVs.
        %
        data = this.gaussianDistribution.icdf(data);
      end

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

  methods (Access = 'private')
    correlation = correlate(this, variables, options)
  end

  methods (Access = 'protected')
    function [distribution, dimensionCount] = configure(this, options)
      this.gaussianDistribution = ProbabilityDistribution.Gaussian();
      this.multiplier = 1;

      distribution = this.gaussianDistribution;
      dimensionCount = this.variables.dimensionCount;

      if this.variables.isIndependent, return; end

      variance = this.variables.variance;
      if this.variables.isFamily('Gaussian');
        correlation = this.variables.correlation;
      else
        correlation = this.correlate(this.variables, options);
      end

      assert(all(diag(correlation) == 1));

      %
      % We want the PCA to operate on the covariance matrix as, in this case,
      % the variances of the random variables will be preperly taken into
      % accound while reducing their dimensionality and providing the
      % importance vector.
      %
      D = diag(sqrt(variance));
      [multiplier, this.importance] = Utils.decorrelate( ...
        D * correlation * D, options.get('reductionThreshold', 1));

      %
      % However, we want the variances to stay with the random variables and
      % the computed multiplier to be responsible only for imposing
      % the needed correlations.
      %
      D = diag(1 ./ sqrt(variance));
      multiplier = D * multiplier;

      this.multiplier = transpose(multiplier);
      dimensionCount = size(this.multiplier, 1);
    end
  end
end
