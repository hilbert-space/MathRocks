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

  properties (Access = 'private')
    distribution
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

    function data = sample(this, samples)
      %
      % Independent normal RVs.
      %
      data = this.distribution.sample(samples, this.dimension);

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
      data = this.distribution.apply(data);

      %
      % Dependent RVs with the desired distributions.
      %
      data = this.variables.invert(data);
    end

    function data = evaluateUniform(this, data)
      %
      % Independent normal RVs.
      %
      data = this.distribution.invert(data);

      %
      % Dependent RVs with the desired distributions.
      %
      data = this.evaluate(data);
    end
  end

  methods (Access = 'private')
    correlation = computeCorrelation(this, rvs)
  end

  methods (Access = 'protected')
    multiplier = computeMultiplier(this, correlation)

    function initialize(this, variables, options)
      initialize@ProbabilityTransformation.Base(this, variables, options);

      this.quadratureOptions = ...
        options.get('quadratureOptions', Options('order', 5));

      this.optimizationOptions = ...
        options.get('optimizationOptions', optimset('TolX', 1e-6));

      this.distribution = ProbabilityDistribution.Normal();

      this.correlation = this.computeCorrelation(variables);
      this.multiplier = this.computeMultiplier(this.correlation);

      this.dimension = size(this.multiplier, 1);
    end
  end
end
