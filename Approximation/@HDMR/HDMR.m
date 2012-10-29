classdef HDMR < handle
  properties (SetAccess = 'private')
    inputCount
    outputCount

    order
    nodeCount

    offset
    interpolants

    expectation
    variance
  end

  methods
    function this = HDMR(f, varargin)
      options = Options(varargin{:});
      this.construct(f, options);
    end
  end

  methods (Access = 'protected')
    construct(this, f, options)
  end
end
