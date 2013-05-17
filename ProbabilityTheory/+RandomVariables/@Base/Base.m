classdef Base < handle
  properties (SetAccess = 'protected')
    dimensionCount
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.dimensionCount = options.dimensionCount;
    end
  end

  methods (Abstract)
    data = icdf(this, data)
    result = isIndependent(this)
    result = isFamily(this, name)
  end
end
