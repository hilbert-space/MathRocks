classdef SquaredExponential < KarhunenLoeve.Base
  properties (SetAccess = 'private')
    correlationLength
    sigma
  end

  methods
    function this = SquaredExponential(varargin)
      this = this@KarhunenLoeve.Base(varargin{:});
    end

    function [ C1, C2 ] = evaluate(this, x1, x2)
      C1 = evaluate@KarhunenLoeve.Base(this, x1, x2);

      if nargout < 2, return; end

      m = length(x1);
      n = length(x2);

      [ x1, x2 ] = meshgrid(x1, x2);

      x1 = x1(:);
      x2 = x2(:);

      C2 = this.sigma^2 * exp(-(x1 - x2).^2 / (2 * this.correlationLength^2));
      C2 = reshape(C2, [ m n ]);
    end
  end

  methods (Access = 'protected')
    [ values, functions ] = construct(this, options)
  end
end
