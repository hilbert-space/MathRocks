classdef Base < handle
  properties (SetAccess = 'private')
    expectation
    deviation
    variance
    correlation
    transformation
    dimensionCount
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.expectation = options.expectation;
      this.deviation = options.deviation;

      [ this.variance, this.correlation ] = this.correlate(options);
      this.transformation = this.transform(this.variance, this.correlation, options);

      this.dimensionCount = this.transformation.dimensionCount;
    end

    function data = evaluate(this, data)
      data = this.postprocess(this.transformation.evaluate(data));
    end

    function data = sample(this, sampleCount)
      data = this.postprocess(this.transformation.sample(sampleCount));
    end

    function string = toString(this)
      string = sprintf('%s(%s)', class(this), ...
        DataHash({ this.expectation, this.deviation, ...
          this.variance, this.correlation }));
    end

    function display(this)
      options = Options( ...
        'Expectation', this.expectation, ...
        'Deviation', this.deviation, ...
        'Dimension', this.transformation.dimensionCount);
      display(options, 'Process variation');
    end
  end

  methods (Abstract, Access = 'protected')
    transformation = transform(this, variance, correlation, options)
  end

  methods (Access = 'private')
    [ variance, correlation ] = correlate(this, options);

    function data = postprocess(this, data)
      %
      % Join the local and global variations
      %
      data = bsxfun(@plus, data(:, end), data(:, 1:(end - 1)));

      data = this.expectation + this.deviation * data;
    end
  end
end
