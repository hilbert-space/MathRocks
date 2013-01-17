classdef Kriging < handle
  properties (SetAccess = 'private')
    model
    performance
  end

  methods
    function this = Kriging(f, varargin)
      options = Options(varargin{:});
      this.construct(f, options);
    end
  end

  methods (Access = 'protected')
    construct(this, f, options)
  end
end
