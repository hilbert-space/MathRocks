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
      sampleCount = size(data, 1);
      if sampleCount == 1
        data = reshape(data, this.temperature.processorCount, []);
      else
        data = reshape(data, sampleCount, ...
          this.temperature.processorCount, []);
      end
    end
  end

  methods (Abstract, Access = 'protected')
    surrogate = configure(this, options)
  end
end
