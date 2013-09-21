classdef Heterogeneous < RandomVariables.Base
  methods
    function this = Heterogeneous(varargin)
      this = this@RandomVariables.Base(varargin{:});
    end

    function data = icdf(this, data)
      for i = 1:this.dimensionCount
        data(:, i) = this.distributions{i}.icdf(data(:, i));
      end
    end

    function result = isFamily(this, name)
      name = [ 'ProbabilityDistribution.', name ];
      for i = 1:this.dimensionCount
        if ~isa(this.distributions{i}, name)
          result = false;
          return;
        end
      end
      result = true;
    end

    function value = subsref(this, s)
      if length(s) == 1 && strcmp('{}', s.type)
        value = builtin('subsref', this.distributions, s);
      else
        value = builtin('subsref', this, s);
      end
    end
  end
end
