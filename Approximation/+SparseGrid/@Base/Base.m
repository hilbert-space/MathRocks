classdef Base < handle
  properties (SetAccess = 'private')
    inputCount
    outputCount

    absoluteTolerance
    relativeTolerance

    minimalNodeCount
    maximalNodeCount

    minimalLevel
    maximalLevel

    verbose
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.inputCount = options.inputCount;
      this.outputCount = options.get('outputCount', 1);

      this.absoluteTolerance = options.get('absoluteTolerance', 1e-6);
      this.relativeTolerance = options.get('relativeTolerance', 1e-2);

      this.minimalNodeCount = options.get('minimalNodeCount', 1e2);
      this.maximalNodeCount = options.get('maximalNodeCount', 1e4);

      this.minimalLevel = options.get('minimalLevel', 2);
      this.maximalLevel = options.get('maximalLevel', 10);

      this.verbose = options.get('verbose', true);
    end

    function values = sample(this, output, sampleCount)
      values = this.evaluate(output, ...
        rand(sampleCount, output.inputCount));
    end

    function display(this, output)
       options = Options( ...
        'inputCount', this.inputCount, ...
        'nodeCount', output.nodeCount);
      display(options, 'Sparse grid');
    end
  end
end
