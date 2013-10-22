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

    function Tdata = sample(this, output, varargin)
      Tdata = reshape(this.surrogate.sample(output, varargin{:}), ...
        [], this.processorCount, output.stepCount);
    end

    function Tdata = evaluate(this, output, varargin)
      Tdata = reshape(this.surrogate.evaluate(output, varargin{:}), ...
        [], this.processorCount, output.stepCount);
    end

    function display(this, varargin)
      this.surrogate.display(varargin{:});
    end
  end
end