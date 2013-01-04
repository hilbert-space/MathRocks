classdef Wafer < handle
  properties (SetAccess = 'private')
    layout
    floorplan
    dieWidth
    dieHeight
  end

  methods
    function this = Wafer(varargin)
      options = Options('columns', 20, 'rows', 20, varargin{:});
      this.construct(options);
    end
  end

  methods (Access = 'private')
    construct(this, options)
  end
end
