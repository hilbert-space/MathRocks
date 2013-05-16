classdef Normal < ProbabilityTransformation.Base
  properties
    %
    % Configuration of the numerical integration procedure
    % used to match the correlation coefficients.
    %
    quadratureOptions

    %
    % Configuration of the numerical root finding procedure
    % used to match the correlation coefficients.
    %
    optimizationOptions
  end

  properties (SetAccess = 'private')
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
    correlation = computeCorrelation(this, rvs)
  end

  methods (Access = 'protected')
    multiplier = computeMultiplier(this, correlation)

    function initialize(this, options)
      initialize@ProbabilityTransformation.Base(this, options);

      this.quadratureOptions = ...
        options.get('quadratureOptions', Options('order', 5));

      this.optimizationOptions = ...
        options.get('optimizationOptions', optimset('TolX', 1e-6));

      this.distribution = ProbabilityDistribution.Normal();

      this.correlation = this.computeCorrelation(options.variables);
      this.multiplier = this.computeMultiplier(this.correlation);

      this.dimensionCount = size(this.multiplier, 1);
    end
  end
end
