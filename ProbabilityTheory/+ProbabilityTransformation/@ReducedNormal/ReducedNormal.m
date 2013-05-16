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

    function initialize(this, options)
      this.threshold = options.threshold;
      initialize@ProbabilityTransformation.Normal(this, options);
    end
  end
end
