classdef Base < Basis.Base
  properties (SetAccess = 'protected')
    minimalLevel
    maximalLevel
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this = this@Basis.Base(options);
      this.minimalLevel = options.get('minimalLevel', 2);
      this.maximalLevel = options.get('maximalLevel', 10);
    end
  end
end
