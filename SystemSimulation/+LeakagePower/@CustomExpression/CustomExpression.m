classdef CustomExpression < LeakagePower.Base
  methods
    function this = CustomExpression(varargin)
      this = this@LeakagePower.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    output = construct(this, Ldata, Tdata, Idata, options)

    function I = evaluate(this, output, L, T)
      I = output.evaluate(L, T);
    end
  end
end
