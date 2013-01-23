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
      data = this.sample(options.get('samples', 1e3), 1);
      Data.observe(data, 'draw', true, options);
    end

    function display(this)
      fprintf('Probability distribution:\n');
      fprintf('  Expectation: %.2f\n', this.expectation);
      fprintf('  Variance:    %.2f\n', this.variance);
    end
  end

  methods (Abstract)
    data = sample(this, samples, dimension)
    data = cdf(this, data)
    data = icdf(this, data)
    data = pdf(this, data)
  end
end
