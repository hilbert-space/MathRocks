classdef LinearInterpolation < LeakagePower.Base
  methods
    function this = LinearInterpolation(varargin)
      this = this@LeakagePower.Base(varargin{:});
    end

    function P = evaluate(this, L, T)
      output = this.output;

      %
      % NOTE: Here we are trying to protect the interpolant
      % from the values outside the data range.
      %
      L = max(min(L, output.Lmax), output.Lmin);
      T = max(min(T, output.Tmax), output.Tmin);

      P = output.powerScale * reshape(output.F(L(:), T(:)), size(L));
    end
  end

  methods (Access = 'protected')
    output = construct(this, Ldata, Tdata, Idata, options)
  end
end
