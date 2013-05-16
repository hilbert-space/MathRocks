classdef Base < handle
  properties (SetAccess = 'protected')
    dimensionCount
    variables
    distribution
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.initialize(options);
    end
  end

  methods (Abstract)
    data = sample(this, sampleCount)
    data = evaluate(this, data)
  end

  methods (Access = 'protected')
    function initialize(this, options)
      this.dimensionCount = options.variables.dimensionCount;
      this.variables = options.variables;
    end
  end
end
