classdef ASGC < handle
  properties (SetAccess = 'private')
    basis

    inputCount
    outputCount

    absoluteTolerance
    relativeTolerance

    minimalLevel
    maximalLevel

    verbose
  end

  methods
    function this = ASGC(varargin)
      options = Options(varargin{:});

      this.basis = Basis.Hat;

      this.inputCount = options.inputCount;
      this.outputCount = options.get('outputCount', 1);

      this.absoluteTolerance = options.get('absoluteTolerance', 1e-4);
      this.relativeTolerance = options.get('relativeTolerance', 1e-2);

      this.minimalLevel = options.get('minimalLevel', 2);
      this.maximalLevel = options.get('maximalLevel', 10);

      this.verbose = options.get('verbose', true);
    end

    function values = evaluate(this, output, nodes)
      values = this.basis.evaluate(output.levels, output.orders, ...
        nodes, output.surpluses);
    end

    function values = sample(this, output, sampleCount)
      values = this.evaluate(output, ...
        rand(sampleCount, output.inputCount));
    end
  end
end
