classdef GaussianProcess < handle
  properties (SetAccess = 'protected')
    nodeMean
    nodeDeviation

    responseMean
    responseDeviation

    nodes
    kernel
    parameters

    inverseK
    inverseKy
  end

  methods
    function this = GaussianProcess(varargin)
      options = Options(varargin{:});
      this.construct(options);
    end
  end

  methods (Access = 'protected')
    construct(this, options);
  end
end
