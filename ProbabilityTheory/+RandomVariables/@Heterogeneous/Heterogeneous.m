classdef Heterogeneous < RandomVariables.Base
  properties (SetAccess = 'protected')
    distributions
    correlation
  end

  methods
    function this = Heterogeneous(distributions, correlation)
      this = this@RandomVariables.Base(correlation.dimension);

      assert(all(this.dimension == length(distributions)), ...
        'The number of distributions is invalid.');

      this.distributions = distributions;
      this.correlation = correlation;
    end

    function data = invert(this, data)
      for i = 1:this.dimension
        data(:, i) = this.distributions{i}.invert(data(:, i));
      end
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
