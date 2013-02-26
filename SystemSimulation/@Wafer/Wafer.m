classdef Wafer < handle
  properties (SetAccess = 'private')
    rowCount
    columnCount

    floorplan
    width
    height
    radius

    dieFloorplan
    dieWidth
    dieHeight

    dieCount
    processorCount
  end

  methods
    function this = Wafer(varargin)
      options = Options('rowCount', 20, 'columnCount', 20, varargin{:});
      this.construct(options);
    end

    function string = toString(this)
      string = Utils.toString([ this.dieCount, this.processorCount ]);
    end
  end

  methods (Access = 'private')
    construct(this, options)
  end
end
