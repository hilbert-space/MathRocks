classdef Single < RandomVariables.Base
  properties (SetAccess = 'protected')
    distribution
  end

  methods
    function this = Single(distribution)
      this = this@RandomVariables.Base(1)
      this.distribution = distribution;
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
