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

    function stats = analyze(this, output)
      stats.expectation = this.basis.computeExpectation( ...
        output.levels, output.orders, output.surpluses);
      stats.variance = this.basis.computeVariance( ...
        output.levels, output.orders, output.surpluses);
    end
  end
end
