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

    function stats = analyze(this, output)
      stats = this.surrogate.analyze(output);
      stats.expectation = this.postprocess(output, stats.expectation);
      stats.variance = this.postprocess(output, stats.variance);
    end

    function data = sample(this, output, varargin)
      data = this.surrogate.sample(output, varargin{:});
      data = this.postprocess(output, data);
    end

    function data = evaluate(this, output, varargin)
      data = this.surrogate.evaluate(output, varargin{:});
      data = this.postprocess(output, data);
    end

    function display(this, varargin)
      this.surrogate.display(varargin{:});
    end
  end

  methods (Access = 'protected')
    function data = postprocess(this, output, data)
      sampleCount = size(data, 1);
      if sampleCount == 1
        data = reshape(data, this.processorCount, []);
      else
        data = reshape(data, sampleCount, this.processorCount, []);
      end
    end
  end

  methods (Abstract, Access = 'protected')
    surrogate = configure(this, options)
  end
end
