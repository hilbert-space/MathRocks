classdef KarhunenLoeve < handle
  properties (SetAccess = 'private')
    kernel
    domainBoundary

    functions
    values

    dimensionCount
  end

  methods
    function this = KarhunenLoeve(varargin)
      options = Options(varargin{:});

      this.kernel = options.kernel;
      this.domainBoundary = options.domainBoundary;

      [ this.functions, this.values ] = this.construct(options);

      this.dimensionCount = length(this.values);
    end

    function C = calculate(this, s, t)
      C = this.kernel(s, t);
    end

    function C = approximate(this, s, t)
      if isvector(s)
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

  methods (Access = 'protected')
    [ functions, values ] = construct(this, options)
  end
end
