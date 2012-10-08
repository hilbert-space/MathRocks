classdef ReducedNormal < ProbabilityTransformation.Normal
  properties
    %
    % The percentage of the variance of the data to preserve.
    %
    threshold
  end

  methods
    function this = ReducedNormal(varargin)
      this = this@ProbabilityTransformation.Normal(varargin{:});
    end
  end

  methods (Access = 'protected')
    multiplier = computeMultiplier(this, correlation)

    function initialize(this, variable, options)
      this.threshold = options.get('threshold', 95);
      initialize@ProbabilityTransformation.Normal(this, variable, options);
    end
  end
end
