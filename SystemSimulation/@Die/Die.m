classdef Die < handle
  properties (SetAccess = 'private')
    filename

    floorplan
    width
    height
    radius

    processorCount
  end

  methods
    function this = Die(varargin)
      this.construct(Options(varargin{:}));
    end

    function string = toString(this)
      string = sprintf('%s(%s)', class(this), this.filename);
    end
  end

  methods (Access = 'private')
    construct(this, options)
  end
end
