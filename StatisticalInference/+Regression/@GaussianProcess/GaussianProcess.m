classdef GaussianProcess < handle
  %
  % Based on:
  %
  % C. Rasmussen and C. Williams. Gaussian Processes for Machine Learning,
  % The MIT press, 2006, pp. 15--16.
  %

  properties (SetAccess = 'protected')
    nodeMean
    nodeDeviation

    responseMean
    responseDeviation

    nodes
    kernel
    arguments

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
