classdef Homogeneous < RandomVariables.Base
  methods
    function this = Homogeneous(varargin)
      this = this@RandomVariables.Base(varargin{:});
    end

    function data = icdf(this, data)
      data = this.distributions.icdf(data);
    end

    function result = isFamily(this, name)
      result = isa(this.distributions, [ 'ProbabilityDistribution.', name ]);
    end

    function value = subsref(this, s)
      if length(s) == 1 && strcmp('{}', s.type)
        value = this.distributions;
      else
        value = builtin('subsref', this, s);
      end
    end
  end
end
