classdef Base < handle
  properties (SetAccess = 'protected')
    distributions
    correlation
    dimensionCount
    isIndependent
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.distributions = options.distributions;
      this.correlation = options.correlation;
      this.dimensionCount = size(this.correlation, 1);
      this.isIndependent = Utils.isIndependent(this.correlation);
    end

    function string = toString(this)
      string = sprintf('%s(%s)', class(this), ...
        Utils.toString(struct( ...
          'distributions', this.distributions, ...
          'correlation', DataHash(this.correlation))));
    end
  end

  methods (Abstract)
    data = icdf(this, data)
    result = isFamily(this, name)
  end
end
