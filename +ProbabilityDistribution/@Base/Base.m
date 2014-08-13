classdef Base < handle
  properties (SetAccess = 'protected')
    expectation
    variance
    support
  end

  methods
    function this = Base
    end

    function plot(this, varargin)
      options = Options(varargin{:});
      data = this.sample(options.get('sampleCount', 1e3), 1);
      Plot.distribution(data, options);
    end

    function result = eq(this, another)
      result = false;

      if ~strcmp(class(this), class(another)), return; end

      names = properties(this);
      for i = 1:length(names)
        if ~all(this.(names{i}) == another.(names{i}))
          return;
        end
      end

      result = true;
    end

    function [total, leftRight] = isBounded(this)
      leftRight = isfinite(this.support);
      total = all(leftRight);
    end

    function string = toString(this)
      string = sprintf('%s(%s)', class(this), ...
        String(struct( ...
          'expectation', this.expectation, ...
          'variance', this.variance, ...
          'support', this.support)));
    end
  end

  methods (Abstract)
    data = sample(this, varargin)
    data = cdf(this, data)
    data = icdf(this, data)
    data = pdf(this, data)
  end
end
