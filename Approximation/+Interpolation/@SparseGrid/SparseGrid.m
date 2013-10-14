classdef SparseGrid < handle
  properties (SetAccess = 'private')
    basis

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
    function this = SparseGrid(varargin)
      options = Options(varargin{:});

      this.basis = Basis.Hat;

      this.inputCount = options.inputCount;
      this.outputCount = options.get('outputCount', 1);

      this.absoluteTolerance = options.get('absoluteTolerance', 1e-4);
      this.relativeTolerance = options.get('relativeTolerance', 1e-2);

      this.minimalNodeCount = options.get('minimalNodeCount', 1);
      this.maximalNodeCount = options.get('maximalNodeCount', 1e4);

      this.minimalLevel = options.get('minimalLevel', 2);
      this.maximalLevel = options.get('maximalLevel', 10);

      this.verbose = options.get('verbose', true);
    end
  end
end
