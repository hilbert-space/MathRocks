classdef Base < handle
  properties (SetAccess = 'private')
    process
    surrogate
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.process = ProcessVariation(options.processOptions);
      this.surrogate = this.configure(options.surrogateOptions);
    end

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

  methods (Abstract, Access = 'protected')
    surrogate = configure(this, options)
  end
end
