classdef Single < RandomVariables.Base
  properties (SetAccess = 'protected')
    distribution
  end

  methods
    function this = Single(distribution)
      this = this@RandomVariables.Base(1)
      this.distribution = distribution;
    end

    function data = icdf(this, data)
      data = this.distribution.icdf(data);
    end

    function result = isIndependent(this)
      result = true;
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
