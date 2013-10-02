classdef Gaussian < ProbabilityTransformation.Base
  properties (SetAccess = 'private')
    gaussianDistribution
    multiplier
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

    function data = evaluate(this, data)
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
    function [ distribution, dimensionCount ] = configure(this, options)
      this.gaussianDistribution = ProbabilityDistribution.Gaussian();
      this.multiplier = 1;

      distribution = this.gaussianDistribution;
      dimensionCount = this.variables.dimensionCount;

      if this.variables.isIndependent, return; end

      if this.variables.isFamily('Gaussian');
        correlation = this.variables.correlation;
      else
        correlation = this.correlate(this.variables, options);
      end

      assert(all(diag(correlation) == 1));

      this.multiplier = transpose(Utils.decomposeCorrelation( ...
        correlation, options.get('reductionThreshold', 1)));
      dimensionCount = size(this.multiplier, 1);
    end
  end
end
