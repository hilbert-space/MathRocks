classdef Base < handle
  properties (SetAccess = 'private')
    basis

    inputCount
    outputCount

    absoluteTolerance
    relativeTolerance

    minimalNodeCount
    maximalNodeCount

    verbose
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.basis = this.configure(options);

      this.inputCount = options.inputCount;
      this.outputCount = options.get('outputCount', 1);

      this.absoluteTolerance = options.get('absoluteTolerance', 1e-6);
      this.relativeTolerance = options.get('relativeTolerance', 1e-2);

      this.minimalNodeCount = options.get('minimalNodeCount', 1e2);
      this.maximalNodeCount = options.get('maximalNodeCount', 1e4);

      this.verbose = options.get('verbose', true);
    end

    function display(this, output)
       options = Options( ...
        'inputCount', this.inputCount, ...
        'nodeCount', output.nodeCount);
      display(options, 'Interpolant');
    end
  end

  methods (Abstract, Access = 'protected')
    basis = configure(this, options)
  end
end
