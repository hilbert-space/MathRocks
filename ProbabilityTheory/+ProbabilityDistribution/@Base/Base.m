classdef Base < handle
  properties (SetAccess = 'protected')
    expectation
    variance
    support
  end

  methods
    function this = Base()
    end

    function plot(this, varargin)
      options = Options(varargin{:});
      data = this.sample(options.get('sampleCount', 1e3), 1);
      Data.observe(data, 'draw', true, options);
    end

    function string = toString(this)
      string = sprintf('%s(%s)', class(this), ...
        Utils.toString(struct( ...
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
