classdef DimensionAdaptive < Interpolation.SparseGrid
  properties (SetAccess = 'private')
    adaptivityDegree
  end

  methods
    function this = DimensionAdaptive(varargin)
      options = Options(varargin{:});
      this = this@Interpolation.SparseGrid(options);

      this.adaptivityDegree = options.get('adaptivityDegree', 0.9);
    end
  end
end
