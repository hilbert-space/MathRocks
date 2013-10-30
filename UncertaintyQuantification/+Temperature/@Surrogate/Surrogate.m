classdef Surrogate < handle
  properties (SetAccess = 'protected')
    surrogate
  end

  methods
    function stats = analyze(this, varargin)
      stats = this.surrogate.analyze(varargin{:});
      stats.expectation = reshape(stats.expectation, this.processorCount, []);
      stats.variance = reshape(stats.variance, this.processorCount, []);
    end

    function data = sample(this, output, varargin)
      data = reshape(this.surrogate.sample(output, varargin{:}), ...
        [], this.processorCount, output.stepCount);
    end

    function data = evaluate(this, output, varargin)
      data = reshape(this.surrogate.evaluate(output, varargin{:}), ...
        [], this.processorCount, output.stepCount);
    end

    function display(this, varargin)
      this.surrogate.display(varargin{:});
    end
  end
end