classdef LinearInterpolation < LeakagePower.Base
  methods
    function this = LinearInterpolation(varargin)
      this = this@LeakagePower.Base(varargin{:});
    end

    function P = evaluate(this, L, T)
      output = this.output;
      P = output.powerScale * ...
        interpolate(output.Lgrid, output.Tgrid, output.Igrid, L, T);
    end
  end

  methods (Access = 'protected')
    output = construct(this, Ldata, Tdata, Idata, options)
  end
end
