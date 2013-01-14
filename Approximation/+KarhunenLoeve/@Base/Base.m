classdef Base < handle
  properties (SetAccess = 'private')
    kernel

    domainBoundary
    dimensionCount

    functions
    values
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.initialize(options);
    end

    function C = calculate(this, s, t)
      C = this.kernel(s, t);
    end

    function C = approximate(this, s, t)
      if ndims(s) == 1
        m = length(s);
        n = length(t);
        [ s, t ] = meshgrid(s, t);
      end

      f = this.functions;
      v = this.values;

      C = 0;
      for i = 1:this.dimensionCount
        C = C + v(i) * f{i}(s) .* f{i}(t);
      end
    end
  end

  methods (Abstract, Access = 'protected')
    [ functions, values ] = construct(this, options)
  end

  methods (Access = 'private')
    function initialize(this, options)
      this.kernel = options.kernel;
      this.domainBoundary = options.domainBoundary;
      [ this.functions, this.values ] = this.construct(options);
      this.dimensionCount = length(this.values);
    end
  end
end
