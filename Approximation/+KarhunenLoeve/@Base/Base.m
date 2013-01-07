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

    function C = evaluate(this, x1, x2)
      m = length(x1);
      n = length(x2);

      [ x1, x2 ] = meshgrid(x1, x2);

      x1 = x1(:);
      x2 = x2(:);

      v = this.values;
      f = this.functions;

      C = 0;

      for i = 1:this.dimension
        C = C + v(i) * f{i}(x1) .* f{i}(x2);
      end

      C = reshape(C, [ m n ]);
    end
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
