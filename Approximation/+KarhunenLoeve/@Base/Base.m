classdef Base < handle
  properties (SetAccess = 'private')
    dimension
    domainBoundary

    values
    functions
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.initialize(options);
    end

    function C = approximate(this, s, t)
      if ndims(s) == 1
        m = length(s);
        n = length(t);
        [ s, t ] = meshgrid(s, t);
      else
        [ m, n ] = size(s);
      end

      s = s(:);
      t = t(:);

      v = this.values;
      f = this.functions;

      C = 0;

      for i = 1:this.dimension
        C = C + v(i) * f{i}(s) .* f{i}(t);
      end

      C = reshape(C, [ m n ]);
    end
  end

  methods (Abstract)
    C = calculate(this, s, t);
  end

  methods (Abstract, Access = 'protected')
    [ values, functions ] = construct(this, options)
  end

  methods (Access = 'private')
    function initialize(this, options)
      this.domainBoundary = options.domainBoundary;
      [ this.values, this.functions ] = this.construct(options);
      this.dimension = length(this.values);
    end
  end
end
