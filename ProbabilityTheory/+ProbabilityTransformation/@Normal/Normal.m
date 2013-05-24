classdef Normal < ProbabilityTransformation.Base
  properties (SetAccess = 'private')
    distribution

    %
    % The correlation matrix as produced by the pure probability
    % transformation.
    %
    correlation

    %
    % The corresponding multiplier produced by some decomposition
    % procedure used to construct RVs with the obtained or approximated
    % correlation matrix.
    %
    multiplier
  end

  methods
    function this = Normal(varargin)
      this = this@ProbabilityTransformation.Base(varargin{:});
    end

    function data = sample(this, sampleCount)
      %
      % Independent normal RVs.
      %
      data = this.distribution.sample(sampleCount, this.dimensionCount);

      %
      % Dependent RVs with the desired distributions.
      %
      data = this.evaluate(data);
    end

    function data = evaluate(this, data)
      %
      % Dependent normal RVs.
      %
      data = data * this.multiplier;

      %
      % Dependent uniform RVs.
      %
      data = this.distribution.cdf(data);

      %
      % Dependent RVs with the desired distributions.
      %
      data = this.variables.icdf(data);
    end
  end

  methods (Access = 'private')
    correlation = computeCorrelation(this, options)
  end

  methods (Access = 'protected')
    multiplier = computeMultiplier(this, correlation, options)

    function initialize(this, options)
      initialize@ProbabilityTransformation.Base(this, options);

      this.distribution = ProbabilityDistribution.Normal();
      this.correlation = this.computeCorrelation(options);
      this.multiplier = this.computeMultiplier(this.correlation, options);

      this.dimensionCount = size(this.multiplier, 1);
    end
  end
end
