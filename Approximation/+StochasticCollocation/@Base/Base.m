classdef Base < handle
  properties (SetAccess = 'private')
    interpolant
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.interpolant = this.configure(options);
    end

    function output = construct(this, varargin)
      output = this.interpolant.construct(varargin{:});
    end

    function values = sample(this, output, sampleCount)
      values = this.interpolant.evaluate(output, ...
        rand(sampleCount, this.interpolant.inputCount));
    end

    function stats = analyze(this, output)
      stats.expectation = this.interpolant.integrate(output);
      stats.variance = NaN(size(stats.expectation));
    end

    function values = evaluate(this, output, nodes, varargin)
      values = this.interpolant.evaluate(output, nodes);
    end

    function plot(this, varargin)
      plot(this.interpolant, varargin{:});
    end

    function display(this, varargin)
      display(this.interpolant, varargin{:});
    end

    function result = inputCount(this)
      result = this.interpolant.inputCount;
    end
  end

  methods (Abstract, Access = 'protected')
    interpolant = configure(this, options)
  end
end
