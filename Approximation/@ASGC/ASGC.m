classdef ASGC < handle
  properties (SetAccess = 'protected')
    inputDimension
    outputDimension

    level
    nodeCount
    levelNodeCount

    nodes
    levelIndex

    surpluses

    expectation
    variance
    secondRawMoment
  end

  methods
    function this = ASGC(f, varargin)
      options = Options(varargin{:});
      this.construct(f, options);
    end
  end

  methods (Access = 'protected')
    construct(this, f, options)
  end
end
