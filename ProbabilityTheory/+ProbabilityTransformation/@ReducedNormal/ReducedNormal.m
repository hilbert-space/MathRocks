classdef ReducedNormal < ProbabilityTransformation.Normal
  methods
    function this = ReducedNormal(varargin)
      this = this@ProbabilityTransformation.Normal(varargin{:});
    end
  end

  methods (Access = 'protected')
    multiplier = computeMultiplier(this, correlation, options)
  end
end
