classdef SquaredExponential < KarhunenLoeve.Base
  properties (SetAccess = 'private')
    correlationLength
    sigma
  end

  methods
    function this = SquaredExponential(varargin)
      this = this@KarhunenLoeve.Base(varargin{:});
    end

    function C = calculate(this, s, t)
      if ndims(s) == 1
        m = length(s);
        n = length(t);
        [ s, t ] = meshgrid(s, t);
      else
        [ m, n ] = size(s);
      end

      C = this.sigma^2 * exp(-(s - t).^2 / (2 * this.correlationLength^2));
      C = reshape(C, [ m n ]);
    end
  end

  methods (Access = 'protected')
    [ values, functions ] = construct(this, options)
  end
end
