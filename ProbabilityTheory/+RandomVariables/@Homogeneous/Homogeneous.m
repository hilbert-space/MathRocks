classdef Homogeneous < RandomVariables.Base
  properties (SetAccess = 'protected')
    distribution
    correlation
  end

  methods
    function this = Homogeneous(varargin)
      options = Options(varargin{:});

      this = this@RandomVariables.Base( ...
        'dimensionCount', size(options.correlation, 1));

      this.distribution = options.distribution;
      this.correlation = options.correlation;
    end

    function data = icdf(this, data)
      data = this.distribution.icdf(data);
    end

    function result = isIndependent(this)
      result = Utils.isIndependent(this.correlation);
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
