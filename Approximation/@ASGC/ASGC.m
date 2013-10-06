classdef ASGC < handle
  properties (SetAccess = 'private')
    basis

    inputCount
    outputCount

    control
    tolerance

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

      this.control = options.get('control', 'NormNormExpectation');
      this.tolerance = options.get('tolerance', 1e-3);

      this.minimalLevel = options.get('minimalLevel', 2);
      this.maximalLevel = options.get('maximalLevel', 10);

      this.verbose = options.get('verbose', true);
    end
  end
end
