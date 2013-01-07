classdef OrnsteinUhlenbeck < KarhunenLoeve.Base
  properties (SetAccess = 'private')
    correlationLength
  end

  methods
    function this = OrnsteinUhlenbeck(varargin)
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

      C2 = exp(-abs(x1 - x2) / this.correlationLength);
      C2 = reshape(C2, [ m n ]);
    end
  end

  methods (Access = 'protected')
    [ values, functions ] = construct(this, options)
  end
end
