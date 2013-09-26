classdef Base < handle
  properties (SetAccess = 'private')
    variables
    distribution
    dimensionCount
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.variables = options.variables;
      [ this.distribution, this.dimensionCount ] = ...
        this.configure(options);
    end

    function string = toString(this)
      string = sprintf('%s(%s)', class(this), ...
        String(struct( ...
          'variables', this.variables, ...
          'distribution', this.distribution, ...
          'dimensionCount', this.dimensionCount)));
    end
  end

  methods (Abstract)
    data = sample(this, sampleCount)
    data = evaluate(this, data)
  end

  methods (Abstract, Access = 'protected')
    [ distribution, dimensionCount ] = configure(this, options)
  end
end
