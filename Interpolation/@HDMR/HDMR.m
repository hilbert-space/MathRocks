classdef HDMR < handle
  properties (SetAccess = 'private')
    inputDimension
    outputDimension

    offset
    interpolants
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
