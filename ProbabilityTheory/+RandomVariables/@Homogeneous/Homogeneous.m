classdef Homogeneous < RandomVariables.Base
  properties (SetAccess = 'protected')
    distribution
    correlation
  end

  methods
    function this = Homogeneous(distribution, correlation)
      this = this@RandomVariables.Base(correlation.dimension);

      this.distribution = distribution;
      this.correlation = correlation;
    end

    function data = invert(this, data)
      data = this.distribution.invert(data);
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
