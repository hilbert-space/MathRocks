classdef Single < RandomVariables.Base
  properties (SetAccess = 'protected')
    distribution
  end

  methods
    function this = Single(varargin)
      options = Options(varargin{:});

      this = this@RandomVariables.Base('dimensionCount', 1);

      this.distribution = options.distribution;
    end

    function data = icdf(this, data)
      data = this.distribution.icdf(data);
    end

    function result = isIndependent(this)
      result = true;
    end

    function result = isFamily(this, name)
      result = isa(this.distribution, [ 'ProbabilityDistribution.', name ]);
    end

    function value = subsref(this, S)
      if length(S) == 1 && strcmp('{}', S.type)
        value = this.distribution;
      else
        value = builtin('subsref', this, S);
      end
    end
  end
end
