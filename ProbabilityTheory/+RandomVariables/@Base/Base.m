classdef Base < handle
  properties (SetAccess = 'protected')
    dimension
  end

  methods
    function this = Base(dimension)
      this.dimension = dimension;
    end
  end

  methods (Abstract)
    data = icdf(this, data)
    result = isIndependent(this)
  end
end
