classdef LinearInterpolation < LeakagePower.Base
  methods
    function this = LinearInterpolation(varargin)
      this = this@LeakagePower.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    output = construct(this, Ldata, Tdata, Idata, options)

    function I = evaluate(this, output, L, T)
      I = reshape(output.F(L(:), T(:)), size(L));
    end
  end
end
