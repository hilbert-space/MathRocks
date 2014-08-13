classdef RandomVariables < handle
  properties (SetAccess = 'protected')
    distributions
    correlation
    dimensionCount
    isIndependent
  end

  methods
    function this = RandomVariables(varargin)
      options = Options(varargin{:});
      this.distributions = options.distributions;
      this.correlation = options.correlation;
      this.dimensionCount = length(this.distributions);
      this.isIndependent = Utils.isIndependent(this.correlation);
    end

    function variance = variance(this)
      variance = cellfun(@(rv) rv.variance, this.distributions);
    end

    function data = icdf(this, data)
      for i = 1:this.dimensionCount
        data(:, i) = this.distributions{i}.icdf(data(:, i));
      end
    end

    function result = isFamily(this, name)
      name = ['ProbabilityDistribution.', name];
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

    function string = toString(this)
      string = sprintf('%s(%s)', class(this), ...
        String(struct( ...
          'distributions', this.distributions, ...
          'correlation', DataHash(this.correlation))));
    end
  end
end
