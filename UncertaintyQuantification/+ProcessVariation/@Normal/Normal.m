classdef Normal < ProcessVariation.Base
  methods
    function this = Normal(varargin)
      this = this@ProcessVariation.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function transformation = transform(this, variance, correlation, options)
      dimensionCount = length(variance);

      distributions = cell(dimensionCount, 1);

      for i = 1:dimensionCount
        distributions{i} = ProbabilityDistribution.Normal( ...
          'mu', 0, 'sigma', sqrt(variance(i)));
      end

      variables = RandomVariables.Heterogeneous( ...
        'distributions', distributions, 'correlation', correlation);

      transformation = ProbabilityTransformation.Normal( ...
        'variables', variables, 'threshold', options.threshold);
    end
  end
end
