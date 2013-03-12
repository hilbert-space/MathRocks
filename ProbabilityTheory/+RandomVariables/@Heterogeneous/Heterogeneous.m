classdef Heterogeneous < RandomVariables.Base
  properties (SetAccess = 'protected')
    distributions
    correlation
  end

  methods
    function this = Heterogeneous(distributions, correlation)
      this = this@RandomVariables.Base(size(correlation, 1));

      assert(all(this.dimension == length(distributions)), ...
        'The number of distributions is invalid.');

      this.distributions = distributions;
      this.correlation = correlation;
    end

    function data = icdf(this, data)
      for i = 1:this.dimension
        data(:, i) = this.distributions{i}.icdf(data(:, i));
      end
    end

    function result = isIndependent(this)
      result = Utils.isIndependent(this.correlation);
    end

    function value = subsref(this, S)
      if length(S) == 1 && strcmp('{}', S.type)
        value = builtin('subsref', this.distributions, S);
      else
        value = builtin('subsref', this, S);
      end
    end
  end
end
