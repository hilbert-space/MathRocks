classdef LinearInterpolation < LeakagePower.Base
  methods
    function this = LinearInterpolation(varargin)
      this = this@LeakagePower.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    output = construct(this, V, T, I, options)

    function I = evaluate(this, output, V, T)
      I = reshape(output.F(V(:), T(:)), size(V));
    end
  end
end
