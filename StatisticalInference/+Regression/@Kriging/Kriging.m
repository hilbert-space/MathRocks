classdef Kriging < handle
  properties (SetAccess = 'protected')
    model
    performance
  end

  methods
    function this = Kriging(varargin)
      options = Options(varargin{:});
      this.construct(options);
    end
  end

  methods (Access = 'protected')
    construct(this, options)
  end
end
