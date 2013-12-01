classdef Base < handle
  properties (SetAccess = 'private')
    temperature
    process
    surrogate
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.temperature = Temperature(options.temperatureOptions);
      this.process = ProcessVariation(options.processOptions);
      this.surrogate = this.configure(options.surrogateOptions);
    end

    function stats = analyze(this, output)
      stats = this.surrogate.analyze(output);
      if ~isempty(stats.expectation)
        stats.expectation = this.postprocess(output, stats.expectation);
      end
      if ~isempty(stats.variance)
        stats.variance = this.postprocess(output, stats.variance);
      end
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
      display(this.surrogate, varargin{:});
    end

    function plot(this, varargin)
      if this.surrogate.inputCount > 3, return; end
      this.surrogate.plot(varargin{:});
    end

    function count = inputCount(this)
      count = this.surrogate.inputCount;
    end

    function string = toString(this)
      string = sprintf('%s(%s)', class(this), String.join('_', ...
        this.temperature.toString, this.process.toString, ...
        this.surrogate.toString));
    end
  end

  methods (Access = 'protected')
    function data = postprocess(this, ~, data)
      processorCount = this.temperature.processorCount;
      sampleCount = size(data, 1);
      if sampleCount == 1
        data = reshape(data, processorCount, []);
      else
        data = reshape(data, sampleCount, processorCount, []);
      end
    end
  end

  methods (Abstract, Access = 'protected')
    surrogate = configure(this, options)
  end
end
