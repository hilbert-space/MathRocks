classdef Heterogeneous < RandomVariables.Base
  properties (SetAccess = 'protected')
    distributions
    correlation
  end

  methods
    function this = Heterogeneous(varargin)
      options = Options(varargin{:});

      this = this@RandomVariables.Base( ...
        'dimensionCount', size(options.correlation, 1));

      assert(all(this.dimensionCount == length(options.distributions)), ...
        'The number of distributions is invalid.');

      this.distributions = options.distributions;
      this.correlation = options.correlation;
    end

    function data = icdf(this, data)
      for i = 1:this.dimensionCount
        data(:, i) = this.distributions{i}.icdf(data(:, i));
      end
    end

    function result = isIndependent(this)
      result = Utils.isIndependent(this.correlation);
    end

    function result = isFamily(this, name)
      result = true;
      for i = 1:this.dimensionCount
        if ~isa(this.distributions{i}, [ 'ProbabilityDistribution.', name ])
          result = false;
          break;
        end
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
